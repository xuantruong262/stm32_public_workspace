# STM32H7 flashing application

Run the host GUI with:

```powershell
python .\flashing_tool\flashing_app.py
```

## Normal update procedure

1. Build the application and select its raw `.bin` output, for example
   `app/app_1/build/Debug/app_1.bin`.
2. Enter the running app CDC port and the bootloader CDC port.  On the current
   board both are normally `COM11`; Windows can assign a different port after
   reset, so use Device Manager when detection times out.
3. Select **Update firmware**, choose the `.bin`, then select **Flash
   firmware**.  The GUI asks the running application to reset to bootloader,
   waits for bootloader `GET_INFO`, and transfers the image to Secondary.
4. A successful window says **Test boot started**.  The new app becomes
   permanent only after it calls `app_bootloader_confirm()`.

The tool accepts an application `.bin` only.  It verifies the vector table,
pads the payload with `0xFF` to a 32-byte Flash-word boundary, calculates CRC32
over that padded payload, and constructs the protocol header.  Do not select
an `.elf` or `.hex`, and do not use a debugger to write an update directly into
Primary.

The host protocol is stop-and-wait.  If the window reports a timeout during a
transfer, cancel/abort and restart the complete update; duplicate write retry
is not yet a supported device feature.
