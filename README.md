# Lenovo ThinkBook 15 G2 ITL: macOS Tahoe 26.7.1 with Iris Xe acceleration

OpenCore EFI for the **Lenovo ThinkBook 15 G2 ITL (20VE)** running **macOS Tahoe 26.7.1 (25G241)** with full graphics acceleration on the Tiger Lake **Iris Xe (8086:9A49)**. This works through [WhateverXe](https://github.com/b00t0x/WhateverXe) and the [WhateverXe Graphics](https://github.com/b00t0x/WhateverXe-Graphics) package by b00t0x.

The laptop's own screen (eDP), Metal, brightness, display sleep/wake, Wi-Fi, audio, touchpad and iCloud all work. The [status table](#what-works) lists what has been tested and what has not.

> This is a personal configuration shared as a reference. It is tuned for this exact model and BIOS. Read the whole page before booting it, and keep a working USB installer around.

## Hardware

| Component | Model |
|---|---|
| Laptop | Lenovo ThinkBook 15 G2 ITL, type 20VE, BIOS F8CN59WW (V2.22) |
| CPU | Intel Core i5-1135G7 (Tiger Lake-U, 4C/8T). CFG Lock is **locked**. |
| iGPU | Intel Iris Xe, 80 EU, 8086:9A49. DVMT pre-allocated is fixed at **60 MB** in this BIOS. |
| Panel | CMN N156HCA-EAB 1920×1080 60 Hz eDP (8 bpc, firmware PWM period 96000 = 200 Hz) |
| RAM | 24 GB DDR4 |
| SSD | Samsung PM991a 512 GB NVMe (144D:A809), plus a Patriot P210 SATA SSD |
| Wi-Fi / BT | Intel AX201 CNVi (8086:A0F0) / Intel BT 8087:0026 |
| Ethernet | Realtek RTL8111/8168 |
| Audio | Realtek ALC257 (AppleALC `layout-id` 11) |
| Touchpad | ELAN06FA, I2C-HID |
| SMBIOS | MacBookPro16,2 |

## What works

| Feature | Status | Notes |
|---|---|---|
| Internal display (eDP 1080p) | ✅ | WhateverXe Tiger Lake eDP path |
| Metal / WindowServer acceleration | ✅ | Metal 2. WindowServer, Chrome and Safari are stable with WhateverXe Graphics **0.3.x** |
| Brightness | ✅ full range | Needs the included WhateverXe patch (see [below](#why-a-patched-whateverxe)) |
| Display sleep / wake | ✅ | |
| H.264 / HEVC hardware decode | ✅ with a workaround | Decode runs on the GPU. Hardware pixel transfer has to be turned off ([Post-install step 3](#post-install)). |
| Wi-Fi | ✅ native | AirportItlwm (Tahoe build) shows in the normal Wi-Fi menu. No AirDrop, Handoff or Continuity on Intel Wi-Fi. |
| Bluetooth | ✅ basic | IntelBluetoothFirmware + IntelBTPatcher + BlueToolFixup |
| Ethernet | ✅ | RealtekRTL8111 |
| Audio (speakers, headphones, mic) | ✅ | Needs AppleHDA restored after install ([Post-install step 2](#post-install)) |
| Touchpad + gestures | ✅ | VoodooI2C + VoodooI2CHID |
| Keyboard, brightness keys | ✅ | VoodooPS2. Cmd and Option are **swapped** so the Win key sits where Option is on a Mac. |
| Battery | ✅ | SMCBatteryManager |
| iCloud, App Store | ✅ | With your own valid SMBIOS |
| iMessage / FaceTime | ⚠️ | Not reliable here: registration keeps getting rejected (IDS status 6001). Still under investigation. |
| System sleep (S3) | ❌ disabled | The PM991a NVMe panics on wake (IONVMeFamily "Controller fatal"), so sleep is turned off with `pmset`. Another SSD may behave differently. |
| HDMI, USB-C DisplayPort | ❓ not tested | WhateverXe supports them on Tiger Lake |
| Webcam, SD card reader | ❓ not tested | |
| Fingerprint reader (Goodix) | ❌ | No macOS driver |

## Contents

```
EFI/                 OpenCore 1.0.8 EFI (BOOT + OC). SMBIOS fields are EMPTY: fill them in first.
ACPI/                Sources (.dsl) of the SSDTs in EFI/OC/ACPI
WhateverXe-patches/  The two patches applied on top of upstream WhateverXe 0.6.1 (git format-patch)
```

### Kexts

| Kext | Version | Purpose |
|---|---|---|
| Lilu | 1.7.2 | Patching framework |
| WhateverXe | 0.6.1 + 2 patches | Iris Xe framebuffer and accelerator support |
| AMFIPass (b00t0x **Mod**) | 1.4.1 | Required by the WhateverXe Graphics signing chain. Upstream AMFIPass does **not** work. |
| VirtualSMC, SMCProcessor, SMCBatteryManager | 1.3.8 | SMC, sensors, battery |
| AppleALC | 1.9.8 | ALC257, layout 11 |
| RestrictEvents | 1.1.6 | |
| NVMeFix | 1.1.3 | |
| AirportItlwm (Tahoe, jzrodriguez98 fork) | 2.4.1 | Wi-Fi on macOS 26 (MinKernel 25) |
| itlwm | 2.3.0 | Wi-Fi on macOS 12–15 only (MaxKernel 24.99.99) |
| IntelBluetoothFirmware, IntelBTPatcher, BlueToolFixup | 2.5.2 / 2.7.2 | Bluetooth |
| RealtekRTL8111 | 3.0.0 | Ethernet |
| VoodooPS2Controller (+Keyboard) | 2.3.7 | Keyboard |
| VoodooI2C, VoodooI2CHID | 2.9.1 | Touchpad. The Tiger Lake LPSS I2C IDs are added to the Info.plist. |
| BrightnessKeys | 1.0.3 | Fn brightness keys |
| USBMap | 1.0 | USB port map for this model |
| AppleBacklightInjector | 1.0 | Backlight curve (`F19T15e7`) for this panel |

### ACPI

| SSDT | Purpose |
|---|---|
| SSDT-PLUG | CPU power management (`plugin-type`) |
| SSDT-EC-USBX | Fake EC + USB power properties |
| SSDT-AWAC | Use the legacy RTC |
| SSDT-PNLF | Backlight device (`_UID` 19), required by WhateverXe |
| SSDT-TPAD | Touchpad `_CRS` for VoodooI2C (with the `_CRS → XCRS` rename in ACPI > Patch) |

### Key config.plist settings

- **boot-args:** `-allow3d -disablegfxfirmware -igfxdvmt dc6config=0`
  - `-allow3d -disablegfxfirmware`: required by WhateverXe.
  - `-igfxdvmt`, plus `framebuffer-patch-enable` and `framebuffer-stolenmem = 0000C003` on `PciRoot(0x0)/Pci(0x2,0x0)`: this BIOS fixes DVMT at 60 MB.
- **csr-active-config:** `030A0000`. SIP must be partially disabled for WhateverXe Graphics (it needs at least `0x803`).
- **Cpuid1Data/Mask:** fakes a supported CPUID for Tiger Lake on Tahoe.
- **Kernel quirks:** `AppleXcpmCfgLock` (CFG Lock is locked) and `DisableIoMapper`.
- **DeviceProperties:**
  - `layout-id = 11` on `Pci(0x1f,0x3)`.
  - `force-polling` on the touchpad I2C controller.
  - `acpi-wake-type` on XHC.
- **SecureBootModel:** `Disabled`.

## Installation

1. **BIOS:** turn off Secure Boot. The rest can stay at defaults; CFG Lock and DVMT cannot be changed here and are handled in the config.
2. **SMBIOS:** generate a **MacBookPro16,2** serial, MLB and SystemUUID with [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) (macserial). Put them in `EFI/OC/config.plist → PlatformInfo → Generic`. Set `ROM` to the MAC address of the Ethernet port.
   - Check the serial at [checkcoverage.apple.com](https://checkcoverage.apple.com): it should come back as **invalid**. If it belongs to a real Mac, generate another one.
3. Copy `EFI` to a USB stick, or to your disk's EFI partition, and boot it.
4. Install **macOS Tahoe 26.7.1 (25G241)**. The graphics package is built for that exact build, so **do not update macOS** until WhateverXe Graphics supports the newer build.
   - During installation the display runs without acceleration. That is expected.
   - Ethernet is the most reliable network option inside the installer.

## Post-install

1. **Graphics:** download and install the latest **WhateverXe Graphics** pkg (0.3.2 was used here) from [its releases page](https://github.com/b00t0x/WhateverXe-Graphics/releases), then restart. It installs into `/Library` and rebuilds the AuxKC. It does not patch the System volume.
2. **Audio:** Tahoe removed AppleHDA. Restore it with the **Modern Audio** root patch of [b00t0x's OpenCore Legacy Patcher fork](https://github.com/b00t0x/OpenCore-Legacy-Patcher). Use the fork rather than upstream OCLP: only the fork uses the same AMFIPass signing chain as the graphics package. Restart afterwards.
   - The author of this EFI installed the same AppleHDA 600.2 manually instead, with an exact-build KDK.
3. **Video decode workaround:** the Tiger Lake VA driver decodes correctly but crashes in GVA's hardware pixel-transfer path. That crash produces broken, blocky video in Chrome and can hang `VTDecoderXPCService`. Keep hardware decode on and turn only the transfer session off. Run this as your user, without sudo, then relaunch your browsers:
   ```sh
   defaults write com.apple.coremedia allowHardwareTransferSession -bool false
   ```
   If video still misbehaves, fall back to full software decode:
   ```sh
   defaults write com.apple.AppleGVA forceSWDecoder -bool true
   defaults write com.apple.coremedia hardwareVideoDecoder -string disable
   ```
4. **Sleep:** with the PM991a, turn sleep off:
   ```sh
   sudo pmset -a sleep 0 disablesleep 1 standby 0 hibernatemode 0 powernap 0 proximitywake 0 tcpkeepalive 0
   ```

## Why a patched WhateverXe

The `WhateverXe.kext` in this EFI is upstream **0.6.1** plus the two patches in `WhateverXe-patches/`:

1. **Backlight PWM period fix (needed on this laptop).** Apple's donor framebuffer derives its PWM period from the PCH raw clock (17777). Lenovo's firmware runs the panel at **96000** (200 Hz).
   - The native `hwSetBacklight` therefore writes duty values against the wrong period. Maximum brightness lands at **18.5 %** of the real range.
   - Using the period alone is not enough: the donor's 32-bit `period × level` product wraps above about 68 % at 96000.
   - The patch reads the period the hardware actually runs and computes the duty with a 64-bit product.
   - It only routes on the known donor build, never on Alder Lake panel paths, and `-wex-blfreq-off` disables it.
2. **Compatibility patch.** It publishes `KextIntelTGLAllowed` on the IGPU and adds `-wex-accel-off`, which keeps the framebuffer but refuses the accelerator; that is useful for rescue. With the WhateverXe Graphics package the patch has no other effect.

To build it yourself:

```sh
git clone https://github.com/b00t0x/WhateverXe && cd WhateverXe
git checkout 0.6.1 && git am /path/to/WhateverXe-patches/*.patch
python3 tools/build.py --release   # needs MacKernelSDK and Lilu, see the WhateverXe README
```

If you use **unpatched** upstream WhateverXe, everything works except that maximum brightness stays dim on panels whose firmware PWM period differs from the donor's.

## Troubleshooting

- **Black screen or WindowServer crash loop after installing the graphics package:** SSH in, or boot Recovery, and move `/Library/Extensions/AppleIntelTGL*.kext` and `/Library/KernelCollections/AuxiliaryKernelExtensions.kc` out of the way. Then reboot. Alternatively, run the package's [`uninstall.sh`](https://github.com/b00t0x/WhateverXe-Graphics/blob/main/uninstall.sh).
- **iCloud sign-in spins forever:** the Mac is waiting for approval from your trusted device. On the iPhone, go to Settings → [your name] → Sign-In & Security → Get Verification Code, and type that code.
- **Disk numbers change between boots** (disk0 and disk1 swap places). Identify disks by their model name, never by number.

## Credits

- [b00t0x](https://github.com/b00t0x): WhateverXe, WhateverXe Graphics, the OCLP fork and AMFIPass Mod
- [Acidanthera](https://github.com/acidanthera): OpenCore, Lilu, VirtualSMC, AppleALC, RestrictEvents, NVMeFix, VoodooPS2, BrightnessKeys
- [OpenIntelWireless](https://github.com/OpenIntelWireless): itlwm, IntelBluetoothFirmware; [jzrodriguez98](https://github.com/jzrodriguez98) for the Tahoe AirportItlwm build
- [VoodooI2C](https://github.com/VoodooI2C/VoodooI2C) team
- [Mieze](https://github.com/Mieze): RealtekRTL8111
- [Dortania](https://dortania.github.io): guides
- [JulioNectar](https://github.com/JulioNectar/Hackintosh-XPS13Plus-IrisXe-Tahoe): Iris Xe Tahoe compiler research that informed WhateverXe Graphics 0.3

All kexts and drivers keep their original licenses. No Apple binaries are included: the Tiger Lake graphics drivers come from the WhateverXe Graphics package, and AppleHDA comes from OCLP.

---

## Tóm tắt tiếng Việt

EFI OpenCore cho **Lenovo ThinkBook 15 G2 ITL** chạy **macOS Tahoe 26.7.1 (25G241)**, có tăng tốc đồ hoạ Iris Xe bằng WhateverXe và gói WhateverXe Graphics của b00t0x. Những gì chạy được và chưa chạy được xem ở [bảng trạng thái](#what-works) phía trên.

**Bắt buộc trước khi dùng:**
- Tự tạo SMBIOS **MacBookPro16,2** (serial, MLB, UUID, ROM). Các trường này trong config đang để trống.
- Cài đúng bản **26.7.1 (25G241)**, và không cập nhật macOS khi gói đồ hoạ chưa hỗ trợ bản mới.

**Sau khi cài:**
1. Cài gói WhateverXe Graphics mới nhất.
2. Khôi phục AppleHDA (âm thanh) bằng Modern Audio của bản OCLP fork của b00t0x.
3. Chạy `defaults write com.apple.coremedia allowHardwareTransferSession -bool false` để video giải mã bằng GPU không bị vỡ hình.
4. Tắt sleep nếu dùng SSD PM991a, vì máy bị panic khi wake.

**Bản vá đèn nền:** WhateverXe trong EFI có thêm bản vá để đèn nền đạt độ sáng tối đa. Không có bản vá, đèn nền chỉ sáng khoảng 18,5%, do chu kỳ PWM của Lenovo (96000) khác chu kỳ driver Apple tự tính (17777).
