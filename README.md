## Summary

In this project, I set out to build a simple operating system from scratch using Assembly language. My main goal was to create a bootloader (compatible with FAT12 floppy disks) and a minimal kernel that could display text to the screen.

### What I Tried To Do

- **Bootloader Creation:** I wrote a bootloader that initializes hardware and loads the kernel from a floppy disk formatted with FAT12. This meant diving into BIOS parameter blocks, disk geometry, and figuring out how to convert logical block addresses (LBA) to cylinder-head-sector (CHS) format.
- **Kernel Development:** The kernel is very basic, but it shows some foundational OS concepts. I set up memory segments, configured the stack, and used BIOS interrupts to print a welcome message (“Welcome to my OS”) to the screen.
- **Makefile Automation:** I automated the process of building both the bootloader and kernel binaries, and then assembling them into a floppy disk image using a Makefile.

### What I Learned

Through this project, I've learned a lot about low-level memory and hardware access, BIOS interrupts for output, disk geometry, and boot sector structure. Setting up a bootable OS image and automating the build process also gave me valuable hands-on experience with how operating systems get loaded and executed.

> **Status:** _In Development_

This OS project is still in development, and I plan to continue working on it—adding new features and completing the core functionality as I learn more about OS internals.
