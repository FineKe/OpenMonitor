# OpenMonitor - Building and Running Instructions

## Opening in Xcode

1. Navigate to the `OpenMonitor` directory
2. Double-click on `OpenMonitor.xcodeproj` to open the project in Xcode
3. Choose your development team in the Signing & Capabilities tab if you want to run it on your device
4. Click the ▶️ (Run) button or press Cmd+R to build and run the application

## Command Line Building

Alternatively, you can build from the command line:

```bash
cd TrafficMonitor
swift build
```

## Application Features

Once running, the application will:

1. Show up in your macOS status bar (menu bar) with current upload/download speeds
2. Update the speeds every second
3. Track total upload and download traffic
4. Allow quitting via the menu that appears when clicking on the status bar item

## Troubleshooting

If you encounter issues with network access:
- Make sure your app has the proper entitlements (already set up in the project)
- Check that your Mac allows the application to monitor network traffic
- Try running with sudo if building from command line

## Technical Details

The application:
- Uses SystemConfiguration to access network interface statistics
- Monitors en0 (typically WiFi) and en1 (typically Ethernet) interfaces
- Runs as a status bar application without a Dock icon (LSUIElement is set to true)
- Updates metrics every second with a Timer 
