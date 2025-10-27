# 🧩 SwapForge — Smart Linux Swap Manager
> _An intelligent Bash utility to create, manage, and delete Linux swap space (LVM or file-based) — developed by Sajibe Kanti._

---

![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)
![Shell](https://img.shields.io/badge/Shell-Bash-orange.svg)
![Status](https://img.shields.io/badge/Status-Stable-brightgreen.svg)

---

## 📖 Overview

**SwapForge** is a fully automated **Linux Swap Manager** written in Bash.  
It intelligently detects your system type (LVM or standard filesystem) and lets you:

- ➕ Add swap dynamically  
- 🗑️ Delete existing swap cleanly  
- ⚙️ Auto-update `/etc/fstab` safely  
- 🧠 Detect system type automatically  
- 💬 Provide clear, colorized feedback and error details  

Built for **sysadmins, DevOps engineers, and hosting providers**, this tool simplifies swap configuration for production environments.

---

## 🚀 Features

✅ Detects LVM or standard file-based system  
✅ Add or delete swap with interactive menu  
✅ Safe, persistent `/etc/fstab` updates  
✅ Beautiful terminal output (colorized)  
✅ Robust error handling and validation  
✅ Fully portable — no dependencies beyond coreutils  
✅ Authorship banner (PrenHost Ltd branding ready)

---

## ⚙️ Installation

```bash
git clone https://github.com/Sajibekanti/swapforge.git
cd swapforge
chmod +x swapforge.sh
