# 10x Your CP Workflow: A Smooth Bash Script to Automate Parsing, Testing & Stressing

Hello Codeforces fam,

Over the past few months, I've been building and using a personal tool that **completely automates** my competitive programming workflow. From **parsing** problems to **checking solutions**, **stress testing**, **debugging**, and even **validating edge cases** — this tool has made my life 10x easier and smoother. And now, I’m excited to share it with you so that you can boost your productivity!

---

## What is this tool?

It’s a **template-driven Bash script** designed to integrate with [Competitive Companion](https://github.com/jmerle/competitive-companion) and streamline everything — whether you're solving problems on **Codeforces, AtCoder, LeetCode, CodeChef**, or anywhere else.

With just one command, you can:

- Parse problems
- Compile and run code
- Switch between fast and debug modes
- Stress test using a brute-force checker
- Validate solutions with custom validators


## Features Breakdown

**1. Fetching:** Grab input & output samples from any major coding platform.

**2. Running:** Instantly checks your solution against sample test cases and clean test feedback in your terminal.

**3. Debug Mode:** 

- Easily toggle between fast and debug compile flags
- Debug flags include:
    - Overflow detection
    - Address sanitization
    - Shows Warnings/errors 
- No need to comment out debug prints before submission

**4. Stress Testing:** It helps you quickly find the test case where your code gives the wrong answer by comparing it with a brute-force solution — great for fixing ```Wrong answer on test 2``` problems.

**5. Validator Support:**

- Perfect for constructive problems where multiple correct  outputs are possible. Suppose the problem says:  

    > You are given a number `n`. Print any two integers whose sum is `n`. Both `2 3` and `4 1` are valid outputs for `n = 5`. A validator script can check if the outputted numbers sum to `n`, rather than requiring a specific answer.
- Script checks whether output is valid, not just identical

**6. Manual Tests:** Add custom test cases manually & run them automatically along with other test cases.

---

## Why Use This?

If you're tired of repetitive setup, manual copying of test cases, comment out dbg(...), or losing time doing stress testing manually, and validate your solution (for constructive) in paper — **this script is built for you**.

It’s all about **automating the boring parts**, so you can focus on the problem-solving that actually matters.

---

## How to Get It?
#### 1. Preparing Your System (Linux/Mac/Windows)
By default, Linux and macOS support Bash scripts natively. But Out of the box, Windows does not support it. To run Bash scripts on Windows, we need to enable WSL (Windows Subsystem for Linux), which allows you to run a full Linux environment directly on Windows.

---


<spoiler summary="Install WSL (Only for windows users)">
Step 1: Open PowerShell as Administrator
> If asked “Do you want to allow this app to make changes to your device?” — Click **Yes**

---

Step 2: Install WSL

Now type this command into the PowerShell window:

```powershell
wsl --install
```
Then press **Enter**.

This command will:

- Turn on WSL
- Install Ubuntu

Step 3: Restart Your Computer

Step 4: Set Up Your Linux User. When your computer restarts, open **Ubuntu** terminal (like powershell) . You'll see a message like:

> Installing, this may take a few minutes...

Then it will ask:

- Enter a **username** → (Type any name, like `john`)
- Enter a **password** → (Type a password and press Enter)

You're done! You can now open your WSL terminal (Ubuntu) and run Bash scripts like on a real Linux system.

Step 5: (optional) Connect to VS Code

Now let's set up your coding environment:
1. **Create a folder for your projects:**
    ```bash
    mkdir codeforces
    cd codeforces
    ```
2. **Open the folder in VS Code:**
    ```bash
    code .
    ```
This will launch Visual Studio Code in your `codeforces` folder, making it easy to manage your files and start coding right away!

</spoiler>


<!-- #### How to Install WSL -->



#### 2. Prerequisites Install 

Before you start, make sure you have the following tools installed on your system: g++, gdb, jq (JSON processor),curl (command-line downloader), git
<!-- , nccat (netcat alternative, for piping data) -->

<!-- #### Install on Linux (Debian/Ubuntu):

```bash
sudo apt update
sudo apt install g++ gdb jq curl git netcat
```

#### Install on macOS (using Homebrew):

```bash
brew install gcc gdb jq curl git ncat
``` -->

<spoiler summary="Install on Linux / Windows(WSL)">
sudo apt update
sudo apt install g++ gdb jq curl git
</spoiler>

<spoiler summary="Install on MacOS">
brew install gcc gdb jq curl git
</spoiler>


<!-- > **Note:**  
> - On Linux, `netcat` is usually available as `nc` or `ncat`.  
> - On macOS, `ncat` is provided by the `nmap` package. If you don't have Homebrew, install it from [brew.sh](https://brew.sh). -->

#### 3. Install the Script

Just copy and paste this command into your terminal:

<spoiler summary="one line copy paste install">
```bash
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/sourav739397/All-In-ONE-cp/main/install.sh)"
```
</spoiler>
<!-- 
```bash
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/sourav739397/All-In-ONE-cp/main/install.sh)"
``` -->

#### Optional: Install Nerd Font for Cool Icons

For an enhanced terminal experience with beautiful icons, you can install a [Nerd Font](https://www.nerdfonts.com/font-downloads). Just download your favorite font from their website and set it as your terminal font. This will make script outputs and prompts look even cooler!

## How to Use the Script ?

After installing the script, here’s a comprehensive walkthrough to get you started:
#### 1. Run the Script

- **Navigate to Your Workspace:**  
    Open a terminal and `cd` into your coding folder (e.g., `cd ~/codeforces`).
- **Start the Script:**  
    ```bash
    cprun --help
    ```
    Running **cprun --help** displays a detailed help menu. This menu lists all available commands, flags, and usage examples for the script. 
---
#### 2. Parse a Problem

To parse input test cases using the Competitive Companion extension, use the `--parse` option:

1. **Open your terminal and run:**
      ```bash
      cprun --parse [here/group]
      ```
    - **No argument (default):**  
    Saves samples in a folder named after the problem (e.g., `A/`).

    - **`here`:**  
    Saves samples in the current directory.

    - **`group`:**  
    Saves samples into contest/problem folders (e.g., `Round123/A/`).

    This lets you organize your test cases exactly how you prefer (exactly where you write solution).
2. Then, in your browser, go to the problem page and click the Competitive Companion extension icon. The script will automatically fetch and save the test cases.

---

#### 3. Compile and Test

To quickly check your solution against the sample test cases, use the `--cp` flag:

```bash
cprun --cp your_solution.cpp
```

- Replace `your_solution.cpp` with the filename of your code.
- Write your solution file in the same folder where you fetched the problem samples. 
> This command will automatically compile your code, run it against all sample inputs, and display a summary of passed/failed cases in your terminal.

---

#### 4. Toggle Debug/Fast Mode
To switch between **Debug** and **Fast** modes, use the `-d` flag when running the script:

```bash
cprun --cp -d your_solution.cpp
```

- **Debug Mode (`-d`):**  
    Compiles your code with debug flags (e.g., `-DLOCAL -fsanitize=address -fsanitize=undefined -fsanitize=signed-integer-overflow -D_GLIBCXX_DEBUG`).  
    This helps catch bugs, undefined behavior, and makes debugging easier.

- **Fast Mode (default):**  
    Compiles with optimization flags (e.g., `-O2`) for speed, suitable for final testing and submission.
<!-- 
> **Tip:**  
You don't need to manually comment out your `dbg(...)` debug prints before submission! The script automatically handles this for you using the following pattern: -->

```cpp
#ifdef LOCAL
#include "debug.h"
#else
#define dbg(...)
#endif
```

When running in **Debug Mode**, `LOCAL` is defined, so `dbg(...)` works as expected. In **Fast Mode** (for submission), `dbg(...)` expands to nothing, so your debug prints are ignored—no need to edit your code!

---
#### 5. Stress Testing

Stress testing helps you catch tricky bugs by comparing your solution against a brute-force or validator approach (to stress test constructive problem) on many generated test cases.


<spoiler summary="Usage">
cprun --stress <your_solution.cpp> <brute_force.cpp/validator.cpp -m> <generator.cpp> <number_of_tests>
</spoiler>
<!-- **Usage:**
```bash
cprun --stress <your_solution.cpp> <brute_force.cpp/validator.cpp> <generator.cpp> <number_of_tests>
``` -->

- `<your_solution.cpp>`: Your main solution.
- `<brute_force.cpp>`: A slow but correct solution for unique-answer problems.
- `<validator.cpp> -m`: A custom validator for problems with multiple valid outputs.
- `<generator.cpp>`: Script to generate random test cases.
- `<number_of_tests>`: Number of tests to run (default: 100).

> **Note:**  
> If your solution fails against the brute-force solution during stress testing, the script will prompt you with:  
> 
> Do you want to add this test case? (Y/N): 
> 
> By choosing **Y**, you can save this failing test case for future checks and debugging. This helps you build a collection of tricky cases to strengthen your solution.

**Examples:**
- For unique solutions (using brute force):
    ```bash
    cprun --stress mysol.cpp brute.cpp gen.cpp 100
    ```
- For multiple valid outputs (using validator):
    ```bash
    cprun --stress mysol.cpp validator.cpp -m gen.cpp 100
    ```
- **-m** used for multiple solution

---

#### 6. Add Custom Tests
To manually add your own custom test cases, use the `-a` flag:

```bash
cprun -a
```
This command will prompt you to enter the input and the expected output for a new test case. The script will save your custom test alongside the parsed samples, and include it automatically in future test runs.

---

#### 7. Validate Solutions with a Custom Checker

For problems where **multiple valid outputs** are possible (like constructive problems), you need a **checker** to verify correctness instead of simply comparing outputs.

**How it works:**

- Write a `checker.cpp` that reads:
    1. Your solution's output
    2. The expected (reference) output

- The checker determines if your output is **valid** (not necessarily identical to the reference), according to the problem's requirements.

**Usage Example:**

```bash
cprun --cp your_solution.cpp -m
```
> must write checker in `checker.cpp` and add **-m** argument.

- The script will:
    - Run your solution to produce output.
    - Run the checker with your produce output, and the expected output .
    - Report whether your solution passes the checker.

**When to use:**  
Use this for problems where there are many correct answers, and you want to ensure your output meets the problem's criteria (e.g., sum to `n`, valid permutation, etc.), not just matches a sample output.

## Tips for an Even Smoother Workflow

While this script works in **any terminal** and does **not require any specific editor or IDE**, using **Visual Studio Code (VS Code)** is highly recommended for the best experience. VS Code offers:

- **Built-in terminal support**: Run all commands directly inside your editor.
- **Custom keyboard shortcuts**: Speed up your workflow by mapping frequent actions to keys.

### Example VS Code Shortcuts

You can set up these handy shortcuts in VS Code to automate common tasks:

- **Alt + F**: Fetch problem samples (parse)
- **Alt + R**: Run your solution
- **Alt + D**: Run with debug flags (executes under `LOCAL`)

To add these shortcuts, copy the [keybindings.json](https://github.com/sourav739397/CP-ToolBox/blob/main/VS-Code%20Setup/keybindings.json) from the repo and import it into your VS Code settings.

> **Note:**  
> This script is **universal**—you can use it in any terminal, with any editor, on any platform. No editor lock-in!



### A special thanks to **SahilH** for writing this blog and sharing these insights with the community!
