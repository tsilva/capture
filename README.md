# 📝 Capture

🧠 A simple CLI tool to quickly capture thoughts and ideas directly to Gmail

## 📖 Overview

Capture helps you implement the "Getting Things Done" (GTD) methodology by providing a quick way to dump thoughts, tasks, and ideas from your mind into Gmail. Instead of keeping these thoughts in your head where they constantly demand attention, Capture lets you quickly send them to your inbox for later review and processing.

The tool uses Gmail's API to send emails to yourself or others, helping you maintain a clear mind and an organized workflow.

## 🚀 Installation

1. Install Python (Python 3.9+ recommended)
2. Install [pipx](https://pypa.github.io/pipx/)
3. Run `pipx install .` from the repository root or install directly from GitHub:

   ```bash
   pipx install git+https://github.com/yourusername/capture.git
   ```

4. Create a `targets.json` file based on the example provided

### Setting up Gmail API

1. Create a project in Google Cloud Platform
2. Enable the Gmail API for your project
3. Go to the Credentials tab
4. Create an OAuth 2.0 Client ID
5. Download the credentials file
6. Save it as `client_secret.json` in the Capture folder

## 🛠️ Usage

### Basic Usage

```bash
capture "target" "Your message here"
```

Where `target` is a key from your `targets.json` file.

### Example

```bash
capture "home" "Buy groceries after work"
```

This will send an email with the subject and body "Buy groceries after work" to the email address configured for the "home" target.

### AutoHotkey Integration

For even faster capture on Windows, you can use the provided AutoHotkey script example:

1. Install AutoHotkey
2. Copy and customize the `autohotkey/capture-home.ahk.example` file
3. Run the script to enable capturing thoughts with a simple F1 keystroke

## ⚙️ Configuration

Create a `targets.json` file based on the example to define your capture destinations:

```json
{
    "home": {
        "from": "myemail@gmail.com",
        "to": "myemail@gmail.com"
    },
    "work": {
        "from": "myemail@gmail.com",
        "to": "workemail@work.com"
    }
}
```

## 📄 License

This project is open source. See the LICENSE file for details.
