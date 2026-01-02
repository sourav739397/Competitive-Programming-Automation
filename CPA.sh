#!/bin/bash

# ==============================================
#  Competitive-Programming-Assistant
# ==============================================
#  Features:
#  - Fast/Debug compilation modes
#  - Test case parsing from Competitive Companion
#  - Automated testing against samples
#  - Case-insensitive and ignore whitespace output comparison
#  - Adding new test cases
#  - Stress testing with generator
#  - Time measurement
#  - Colorful output with icons
#  - self-update capability
# ==============================================


# Global flags for compilation
# (need change to mapfile for dynamic includes)
mapfile -t INCLUDES < <(find ~/.CPA -type d -print0 | xargs -0 -I{} echo "-I{}")
FAST_COMPILE=(g++ "${INCLUDES[@]}" -fdiagnostics-color=always -std=c++23 -O2 -o)
DEBUG_COMPILE=(g++ "${INCLUDES[@]}" -DLOCAL -fdiagnostics-color=always -std=c++23 -Wshadow -Wall -Wno-unused-result -g -fsanitize=address -fsanitize=undefined -fsanitize=signed-integer-overflow -fno-omit-frame-pointer -D_GLIBCXX_DEBUG -o)

# Default values
CMD=""
SOURCE_FILE=""
TIMEOUT_DURATION=10  # seconds
COMPILE_SCRIPT=("${FAST_COMPILE[@]}")

# Stress testing defaults
WRONG_SOLUTION="sol.cpp"
SLOW_SOLUTION="slow.cpp"
GENERATOR="gen.cpp"
TEST_COUNT=5000


# ================ HELP FUNCTION ================
show_help() {
  cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                !#  COMPETITIVE PROGRAMMING ASSISTANT                         ║
╚══════════════════════════════════════════════════════════════════════════════╝

USAGE: CPA [OPTIONS] [COMMAND] <source_file.cpp>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  COMMANDS:

  --parse               Parse problem from Competitive Companion
                        Option 1: Save sample info under Problem Name
                        Usage: CPA --parse
                        Option 2: Save sample info under given file name
                        Usage: CPA --parse sol.cpp
                         
  --test <file.cpp>     Compile and test solution against samples
                        Usage: CPA --test sol.cpp
                         
  --add <file.cpp>      Add custom test case interactively
                        Usage: CPA --add sol.cpp
                         
  --stress [args]       Run stress testing (Wrong vs Slow)
                        Usage: CPA --stress [wrong solution] 
                               [slow solution] [generator] [count]
                        Default: sol.cpp slow.cpp gen.cpp 5000
                         
  --help                Show this help message
                        Usage: CPA --help
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

󰘵  OPTIONS:

  -d                    Debug mode (sanitizers + debug symbols)
                        Usage: CPA -d sol.cpp
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  RESOURCES:

  Author: sourav739397@gmail.com
  GitHub: https://github.com/sourav739397/Competitive-Programming-Assistant
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}


# ================ PARSE PROBLEM FROM COMPETITIVE COMPANION ================
parse_problem() {
  local PORT=1327
  echo -e "\033[1;33m󰮏\033[0m  Click the Parse Task in your browser"

  # Listen for data from Competitive Companion
  local data=$(nc -l -p "$PORT" | tr -d '\r' | sed '1,/^$/d' | jq -c '.' 2>/dev/null)

  if [ -z "$data" ]; then 
    echo -e "\033[1;31m  No valid data received\033[0m"
    return 1
  fi

  # Extract problem information
  local problem_name=$(echo "$data" | jq -r '.name')
  local contest_name=$(echo "$data" | jq -r '.group')
  local url=$(echo "$data" | jq -r '.url')
  local tests=$(echo "$data" | jq '.tests')
  local contest_number=$(echo "$url" | grep -oE '[0-9]+')
  local time_limit_ms=$(echo "$data" | jq -r '.timeLimit')
  local time_limit_sec=$(awk "BEGIN {printf \"%.2f\", $time_limit_ms/1000}")
  local memory_limit=$(echo "$data" | jq -r '.memoryLimit')

  # Format names
  contest_name=$(echo "$contest_name" | sed -E 's/^[^ ]+ - (.*)$/\1/' | sed 's/[^a-zA-Z0-9 ]//g' | tr ' ' '_')
  problem_name=$(echo "$problem_name" | sed 's/[^a-zA-Z0-9.]//g' | tr -d ' ')

  # Codeforces specific formatting
  # if [[ "$contest_name" == *"Codeforces"* ]]; then 
  #   contest_name="CF$contest_number"
  # fi 

  # source file handling
  SOURCE_FILE="${SOURCE_FILE:-${problem_name}.cpp}"
  if [[ ! -f "$SOURCE_FILE" ]]; then
    touch "$SOURCE_FILE"
  fi

  # Open it in VS Code (change this if you use a different editor)
  if command -v code &> /dev/null; then
    code "$SOURCE_FILE" 2>/dev/null &
  fi

  local base_name="${SOURCE_FILE%.*}"

  # create .info directory if not exists
  local dir="./.info"
  mkdir -p "$dir"
  echo "$time_limit_sec" > "${dir}/${base_name}_time_limit.txt"

  # clean old test cases
  rm -f $dir/${base_name}_sample*.{in,out}

  # Save test cases with problem name prefix
  local index=1
  echo "$tests" | jq -c '.[]' | while read -r test; do
    local input=$(echo "$test" | jq -r '.input')
    local output=$(echo "$test" | jq -r '.output')
    echo "$input" > "${dir}/${base_name}_sample${index}.in"
    echo "$output" > "${dir}/${base_name}_sample${index}.out"
    # echo -e "󰄲  Saved: ${base_name}_sample${index}.in & ${base_name}_sample${index}.out"
    ((index++))
  done

  local total=$(ls "$dir/${base_name}_sample"*.in 2>/dev/null | wc -l)
  echo -e "\033[1;32m  Sample saved:\033[0m $base_name.cpp\033[1;35m[$total]\033[0m"

  # Display problem information in tree style
  echo -e "\033[1;36m󱁯  Problem Information:\033[0m"
  echo -e "  ├─ Problem name: $problem_name"
  echo -e "  ├─ File name: $SOURCE_FILE"
  echo -e "  ├─ Time limit: ${time_limit_sec}SEC"
  echo -e "  ├─ Memory limit: ${memory_limit}MB"
  echo -e "  └─ URL: $url"
  exit 0
}


# ================ COMPILATION ================
compile_file() {
  local source_file=$1
  local executable=$2
  
  echo -e "\033[1;35m  Compiling:\033[0m $source_file"

  # Compile the source file
  "${COMPILE_SCRIPT[@]}" $executable $source_file &> compilation.log

  # Check for compilation errors
  if grep -q "error:" compilation.log; then
    echo -e "\033[1;31m  Compilation failed:\033[0m $source_file"
    # cat compilation.log | grep "error:"
    cat compilation.log
    rm -f compilation.log
    return 1
  fi

  # Check for warnings
  if grep -q "warning:" compilation.log; then
    echo -e "\033[1;33m  Compilation warning:\033[0m $source_file"
    cat compilation.log | grep "warning:"
  fi
  rm -f compilation.log
  echo -e "\033[1;32m󰄲  Compilation successful:\033[0m $source_file"
  return 0
}


# ================ RUN TEST CASE ================
run_test() {
  local executable=$1
  local total_tests=0
  local passed_tests=0
  
  # Read timeout duration from time limit file
  local problem_name="$executable"
  local time_limit_file="./.info/${problem_name}_time_limit.txt"
  local timeout_duration="$TIMEOUT_DURATION"
  
  if [[ -f "$time_limit_file" ]]; then
    timeout_duration=$(cat "$time_limit_file")
  fi
    
  for input_file in $(ls ./.info/${executable}_sample*.in 2>/dev/null | sort -V); do
    [[ -f "$input_file" ]] || continue
      
    local index="${input_file//[^0-9]/}"
    local output_file="${input_file%.in}.out"
      
    ((total_tests++))
      
    # Check if output file exists
    if [[ ! -f "$output_file" ]]; then
      echo -e "\033[1;31m  Missing output for test $index!\033[0m"
      continue
    fi
      
    # Run the solution
    local start_time=$(date +%s%N)
    local timeout_cmd="timeout $timeout_duration"
    $timeout_cmd ./"$executable" < "$input_file" > output.out
    
    local exit_code=$?
    local end_time=$(date +%s%N)
    local execution_time=$(((end_time - start_time) / 1000000))
    
    # Handle timeout
    if (( exit_code == 124 )); then
      echo -e "\033[1;37m󱫌  Sample Test #$index:\033[0m \033[1;33mTIME LIMIT EXCEEDED\033[0m (\033[0;33mTime: ${execution_time}ms\033[0m)"
      continue
    fi
      
    # Handle runtime errors
    if (( exit_code != 0 )); then
      echo -e "\033[1;37m  Test #$index:\033[0m \033[1;31mRUNTIME ERROR\033[0m"
      if [[ -s runtime.err ]]; then
        echo -e "\033[31m$(cat runtime.err)\033[0m"
      fi
      continue
    fi
        
    # Compare outputs
    # if cmp -s <(normalize_output < output.out) <(normalize_output < "$output_file"); then (case insensitive, ignore trailing spaces)
    if cmp -s output.out "$output_file"; then
      ((passed_tests++))
      echo -e "\033[1;37m󰄲  Sample Test #$index:\033[0m \033[1;32mACCEPTED\033[0m (\033[0;33mTime: ${execution_time}ms\033[0m)"
    else
      echo -e "\033[1;37m  Sample Test #$index:\033[0m \033[1;31mWRONG ANSWER\033[0m (\033[0;33mTime: ${execution_time}ms\033[0m)"
      echo -e "\033[4;36m  Input:\033[0m"
      cat  "$input_file"
      print_comparison "$output_file" "output.out"
    fi
  done
    
  # Cleanup
  rm -f output.out runtime.err "$executable" 2>/dev/null
  
  # Final Score
  echo -ne "\033[1;36m  Final Score: \033[0m"
  echo -e "\033[1;31m$((total_tests - passed_tests))\033[0m /\033[1;32m $passed_tests\033[0m / \033[1;37m$total_tests\033[0m"
}


# ================ ADD TEST CASE ================
add_test_case() {
  local dir="./.info"
  mkdir -p "$dir"
  local problem_name="${SOURCE_FILE%.*}"
  local count=$(ls $dir/${problem_name}_sample*.in 2>/dev/null | wc -l)
  local new_input="$dir/${problem_name}_sample$((count + 1)).in"
  local new_output="$dir/${problem_name}_sample$((count + 1)).out"
  
  echo -e "\033[0;33m \033[0m Enter input (press Ctrl+D when finished):"
  cat > "$new_input"
  
  echo -e "\033[0;33m \033[0m Enter expected output (press Ctrl+D when finished):"
  cat > "$new_output"

  echo -e "\033[1;32m  Sample saved:\033[0m $problem_name.cpp\033[1;35m[$((count + 1))]\033[0m"
}


# ================ STRESS TESTING ================
stress_test() {
    # Check if all required files exist
  if [[ ! -f "$WRONG_SOLUTION" ]]; then
    echo -e "\033[1;31m  File missing:\033[0m $WRONG_SOLUTION"
    return 1
  fi
  
  if [[ ! -f "$SLOW_SOLUTION" ]]; then
    echo -e "\033[1;31m  File missing:\033[0m $SLOW_SOLUTION"
    return 1
  fi
  
  if [[ ! -f "$GENERATOR" ]]; then
    echo -e "\033[1;31m  File missing:\033[0m $GENERATOR"
    return 1
  fi

  echo -e "\033[1;36m  Preparing stress test:\033[0m"
  echo -e "   ├─ Wrong solution: $WRONG_SOLUTION"
  echo -e "   ├─ Slow solution: $SLOW_SOLUTION"
  echo -e "   ├─ Generator: $GENERATOR"
  echo -e "   └─ Test count: $TEST_COUNT"

  # Compile all required files
  if ! compile_file "$WRONG_SOLUTION" "wrong"; then return 1; fi
  if ! compile_file "$SLOW_SOLUTION" "slow"; then return 1; fi
  if ! compile_file "$GENERATOR" "gen"; then return 1; fi

  # local anim_frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')  # Braille spinner
  # local anim_frames=('◇' '◆' '◇' '◆')
  # local anim_frames=('|' '/' '-' '\\')  # Classic spinner
  # local anim_frames=('◐' '◓' '◑' '◒')  # Circle spinner
  # local anim_frames=('▖' '▘' '▝' '▗')  # Quarter block spinner
  # local anim_frames=('⠁' '⠂' '⠄' '⡀' '⢀' '⠠' '⠐' '⠈')  # Dots spinner
  # local anim_frames=('O~~~~' '~O~~~' '~~O~~' '~~~O~' '~~~~O')  # Dots spinner
  # Pacman animation frames (for fun)
  local anim_frames=('ᗧ···' 'ᗧ··' 'ᗧ·' 'ᗧ' 'C·' 'ᗤ·' 'ᗤ··' 'ᗤ···')
  # local anim_frames=('⠋~O~~~ ' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local anim_index=0
  local num_frames=${#anim_frames[@]}

  for ((testNum=1; testNum<=TEST_COUNT; testNum++)); do
    # Animation
    if (( testNum % 50 == 0 )); then  # Update animation every 50 tests
      anim_char="${anim_frames[anim_index]}"
      printf "\r\033[1;34m  Stress testing:\033[0m [%d/%d] %s" "$testNum" "$TEST_COUNT" "$anim_char"
      anim_index=$(( (anim_index + 1) % num_frames ))
    fi

    # Generate test case
    ./gen $testNum > input
    ./slow < input > outSlow
    ./wrong < input > outWrong
    if ! cmp -s "outWrong" "outSlow"; then
      echo -e "\033[1;31m  WRONG ANSWER:\033[0m test #$testNum"
      echo -e "\033[4;36m  Input:\033[0m"
      cat input
      print_comparison "outSlow" "outWrong"

      # Ask if the user wants to save it
      echo -ne "\033[1;33m󰡯\033[0m  Save failed test case? (y/N):"
      read -r choice
      if [[ "$choice" =~ ^[Yy]$ ]]; then
        save_failed_test "input" "outSlow" "$WRONG_SOLUTION"
      fi

      # Cleanup and exit
      rm -f wrong slow gen input outSlow outWrong 2>/dev/null
      exit
    fi      
  done
  # Clear animation line after loop
  echo -ne "\r\033[K"
  echo -e "\033[1;32m󰄲  Passed:\033[0m $TEST_COUNT tests successfully!"

  # Cleanup
  rm -f wrong slow gen input outSlow outWrong 2>/dev/null
}



# ================ SAVE FAILED TEST CASE ================
save_failed_test() {
  local input=$1 output=$2 problem_name=$3
  problem_name="${problem_name%.*}"
  local dir="./.info"
  mkdir -p "$dir"

  local prefix="$dir/${problem_name}_sample$(( $(ls "$dir/${problem_name}_sample"*.in 2>/dev/null | wc -l) + 1 ))"

  cp "$input" "${prefix}.in"
  cp "$output" "${prefix}.out"

  local total=$(ls "$dir/${problem_name}_sample"*.in 2>/dev/null | wc -l)
  echo -e "\033[1;32m  Sample saved:\033[0m $problem_name.cpp\033[1;35m[$total]\033[0m"
}


# Normalize output for comparison
normalize_output() {
  tr '[:upper:]' '[:lower:]' | tr -s ' ' | sed 's/[[:space:]]*$//' | awk 'NF {print}'
}


# =============== PRINT COMPARISON ================
print_comparison() {
  local expected="$1"
  local actual="$2"

  local expected_lines actual_lines max_file_lines
  expected_lines=$(wc -l < "$expected")
  actual_lines=$(wc -l < "$actual")
  max_file_lines=$(( expected_lines > actual_lines ? expected_lines : actual_lines ))

  # echo -e "\033[4;36m  Comparison:\033[0m"
  line_num=1
  exec 3<"$expected" 4<"$actual"  # Open files for reading

  # Print the top border and column headers
  echo "┌────┬────────────────────────────────────┬────────────────────────────────────┐"
  echo -e  "│ L  │            \033[1;35mOutput\033[0m                  │              \033[1;33mExpected\033[0m              │"
  echo "└────┴────────────────────────────────────┴────────────────────────────────────┘"

  while (( line_num <= max_file_lines )); do
    read -r o_line <&3
    read -r a_line <&4

    # If one line is empty, print it as blank
    [[ -z "$o_line" ]] && o_line=" "  
    [[ -z "$a_line" ]] && a_line=" "

    # Apply colors to only the Output column
    if [[ "$o_line" == "$a_line" ]]; then
      # Green for matching lines in Output
      printf "│ %-2s │ \033[0;32m%-34s\033[0m │ %-34s │\n" "$line_num" "$a_line" "$o_line"
    else
      # Red for differing lines in Output
      printf "│ %-2s │ \033[0;31m%-34s\033[0m │ %-34s │\n" "$line_num" "$a_line" "$o_line"
    fi

    ((line_num++))
  done
  echo "└────┴────────────────────────────────────┴────────────────────────────────────┘"
  exec 3<&- 4<&-
}


# ================ COMMAND LINE ARGUMENTS PARSING ================
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      show_help
      exit 0
      ;;
    --parse)
      CMD="parse"
      shift
      if [[ -n "$1" && ("$1" == "here" || "$1" == "group") ]]; then
        SAMPLE_DIR="$1"
        shift
      fi
      ;;
    --test)
      CMD="test"
      shift
      ;;
    --stress)
      CMD="stress"
      shift
      # Handle optional arguments
      if [[ -n "$1" && "$1" != -* ]]; then WRONG_SOLUTION="$1"; shift; fi
      if [[ -n "$1" && "$1" != -* ]]; then SLOW_SOLUTION="$1"; shift; fi
      if [[ -n "$1" && "$1" != -* ]]; then GENERATOR="$1"; shift; fi
      if [[ -n "$1" && "$1" != -* && $1 =~ ^[0-9]+$ ]]; then TEST_COUNT="$1"; shift; fi
      ;;
    --add)
      CMD="add"
      shift
      ;;
    -d)
      COMPILE_SCRIPT=("${DEBUG_COMPILE[@]}")
      shift
      ;;
    *.cpp|*.c)
      SOURCE_FILE="$1"
      shift
      ;;
    *)
      echo -e "\033[1;31m  Unknown command [$1]:\033[0m For help run \033[1;33mCPA --help\033[0m"
      exit 1
      ;;
  esac
done


# =============== MAIN EXECUTION ================
case "$CMD" in
  "parse")
    parse_problem
    ;;
  "test")
    if [[ -z "$SOURCE_FILE" ]]; then
      echo -e "\033[1;31m  No source file:\033[0m For help run \033[1;33mCPA --help\033[0m"
      exit 1
    fi

    # Complile
    executable="${SOURCE_FILE%.*}"
    if ! compile_file "$SOURCE_FILE" "$executable"; then
      exit 1
    fi

    # Checking test cases
    run_test "$executable"
    exit 0
    ;;
  "add")
    if [[ -z "$SOURCE_FILE" ]]; then
      echo -e "\033[1;31m  No source file:\033[0m For help run \033[1;33mCPA --help\033[0m"
      exit 1
    fi
    add_test_case
    exit 0
    ;;
  "stress")
    stress_test
    exit $?
    ;;
  *)
    # Default mode - run the program
    if [[ -z "$SOURCE_FILE" ]]; then
      echo -e "\033[1;31m  No source file:\033[0m For help run \033[1;33mCPA --help\033[0m"
      exit 1
    fi
    executable="${SOURCE_FILE%.*}"
    if ! compile_file "$SOURCE_FILE" "$executable"; then
      exit 1
    fi  
    echo -e "\033[1;34m  Running:\033[0m $SOURCE_FILE"
    timeout --foreground 100 ./$executable
    # rm -f "$executable" 2>/dev/null
    ;;
esac

exit 0