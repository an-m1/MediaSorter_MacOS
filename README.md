# MediaSorter — macOS Media Organization Tool

<p align="center">
  <img src="https://github.com/an-m1/MediaSorter_MacOS/blob/main/images/ico.png?raw=true"
       alt="MediaSorter Icon"
       width="150">
</p>

**MediaSorter** is a native macOS application designed to efficiently organize large collections of images and videos using a fast, keyboard-driven workflow.  
It removes the friction of drag-and-drop sorting by allowing users to preview media and route files to destination folders using simple shortcuts.

This project was built to explore **usability-focused desktop tooling**, **SwiftUI application architecture**, and **human-centered workflow optimization** on macOS.

---

## Why MediaSorter?

Sorting hundreds or thousands of photos and videos is a common but tedious task. Finder-based workflows are slow, mouse-heavy, and interrupt visual focus.

MediaSorter solves this by:
- Keeping your **hands on the keyboard**
- Providing **instant visual feedback**
- Reducing sorting actions to a single keystroke
- Supporting **both images and videos** in one interface

The result is a significantly faster and more pleasant media organization experience.

---

## Key Features

- 📁 Select a **source folder** containing images and videos
- 🗂 Define multiple **destination folders** (e.g., events, categories)
- ⌨️ Keyboard-driven sorting workflow
- 🖼 High-quality image preview
- 🎬 Inline video playback with play/pause
- 🔢 Route files using number keys (1–9)
- ↩️ Undo last move
- 🗑 Move files to Trash when needed
- ✨ Clean, modern macOS UI inspired by Apple’s design language

---

## Supported Media Types

MediaSorter automatically detects common formats supported by macOS:

- **Images:** JPG, PNG, HEIC, TIFF, GIF
- **Videos:** MP4, MOV, M4V (and other AVFoundation-supported formats)

---

## Screenshots

<p align="center">
   <em>Main MediaSorter interface allowing for the user to select source and destination folders.</em>
  <img src="https://github.com/an-m1/MediaSorter_MacOS/blob/main/images/homepage.png?raw=true"
       alt="MediaSorter main interface"
       width="800">
</p>

<p align="center">
  <em>MediaSorter sorting interface showing media preview, destination folders, and media editing.</em>
  <img src="https://github.com/an-m1/MediaSorter_MacOS/blob/main/images/sorting_sample.png?raw=true"
       alt="MediaSorter main interface"
       width="800">
</p>

---

## Usage Demo (Typical Workflow)

1. Launch **MediaSorter**
2. Select a source folder containing media
3. Add destination folders (e.g., “Day 1”, “Day 2”, “Highlights”)
4. Navigate files using ← / →
5. Press **1–9** to instantly sort the current file
6. Repeat — no dragging, no context switching

---

## Keyboard Shortcuts

| Key | Action |
|---|---|
| ← / → | Previous / Next file |
| 1–9 | Move file to destination |
| Space | Play / pause video |
| U | Undo last move |
| Delete | Move file to Trash |

---

## Installation (Recommended)

### Download from GitHub Releases

Prebuilt versions of MediaSorter are available in the **Releases** section of this repository.

Each release includes:
- A **`.dmg` installer**
- A **`.zip` archive** for easy reproduction and testing

### Steps:
1. Download the latest release
2. Extract the ZIP located in the `app-download` folder
3. Open the `.dmg`
4. Drag **MediaSorter.app** into **Applications**
5. Launch the app

> On first launch, macOS may display a security warning.  
> Right-click the app → **Open** → confirm.

---

## Building from Source

```bash
git clone https://github.com/<your-username>/MediaSorter.git
cd MediaSorter
open MediaSorter.xcodeproj
```

- Target: **My Mac**
- Language: **Swift**
- UI Framework: **SwiftUI**
- Media Playback: **AVFoundation**

---

## Design & Technical Notes

- Built entirely with **native macOS frameworks**
- Emphasizes **keyboard-first interaction**
- Separates UI, file system logic, and media handling for clarity
- Designed to scale comfortably to **thousands of files**
- UI optimized for clarity at small icon and window sizes

---

## Use Cases

- Organizing vacation photos by day or location
- Sorting large video shoots or recordings
- Cleaning up camera dumps
- Preparing curated media collections quickly

---

## Future Improvements

- Persistent destination presets
- Smart auto-suggestions based on filenames or dates
- Thumbnail grid overview mode
- Drag-and-drop destination reordering
- Optional tagging system

---

## Author

**Ankit Modhera**  
Computer Science — York University  

This project was built as a practical exploration of **desktop usability**, **SwiftUI architecture**, and **workflow-focused tool design**.

Built with SwiftUI and native macOS frameworks.
