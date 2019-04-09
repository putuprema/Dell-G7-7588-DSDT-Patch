// All required SSDT patches is here
//
// Credits to rehabman for the template http://github.com/rehabman
//
DefinitionBlock("", "SSDT", 2, "hack", "7588", 0)
{
    // SSDT patches for ALC256
    //
    // Credits to vbourachot
    // From: https://github.com/vbourachot/XPS13-9350-OSX/blob/master/ssdt/SSDT-ALC256.dsl
    //
    External(_SB.PCI0.HDEF, DeviceObj)
    Name(_SB.PCI0.HDEF.RMCF, Package()
    {
        "CodecCommander", Package()
        {
            "Custom Commands", Package()
            {
                Package(){}, // signifies Array instead of Dictionary
                Package()
                {
                    // 0x19 SET_PIN_WIDGET_CONTROL 0x25
                    "Command", Buffer() { 0x01, 0x97, 0x07, 0x25 },
                    "On Init", ">y",
                    "On Sleep", ">n",
                    "On Wake", ">y",
                },
                Package()
                {
                    // 0x21 SET_UNSOLICITED_ENABLE 0x83
                    "Command", Buffer() { 0x02, 0x17, 0x08, 0x83 },
                    "On Init", ">y",
                    "On Sleep", ">n",
                    "On Wake", ">y",
                },
                Package()
                {
                    // 0x20 SET_COEF_INDEX 0x36
                    "Command", Buffer() { 0x02, 0x05, 0x00, 0x36 },
                    "On Init", ">y",
                    "On Sleep", ">n",
                    "On Wake", ">y",
                },
                Package()
                {
                    // 0x20 SET_PROC_COEF 0x1737
                    "Command", Buffer() { 0x02, 0x04, 0x17, 0x37 },
                    "On Init", ">y",
                    "On Sleep", ">n",
                    "On Wake", ">y",
                },
            },
            "Perform Reset", ">n",
            "Perform Reset on External Wake", ">n", // enable if using AppleALC
            "Send Delay", 10,
            "Sleep Nodes", ">n",
        },
    })
    
    // SSDT patches for brightness control
    //
    // Credits to rehabman for the guide https://www.tonymacx86.com/threads/guide-laptop-backlight-control-using-applebacklightfixup-kext.218222/
    //
    External (_SB_.PCI0.IGPU, DeviceObj)    // (from opcode)
    External (RMCF.BKLT, IntObj)    // (from opcode)
    External (RMCF.FBTP, IntObj)    // (from opcode)
    External (RMCF.GRAN, IntObj)    // (from opcode)
    External (RMCF.LEVW, IntObj)    // (from opcode)
    External (RMCF.LMAX, IntObj)    // (from opcode)

    Scope (_SB.PCI0.IGPU)
    {
        OperationRegion (RMP3, PCI_Config, Zero, 0x14)
    }

    Device (_SB.PCI0.IGPU.PNLF)
    {
        Name (_ADR, Zero)  // _ADR: Address
        Name (_HID, EisaId ("APP0002"))  // _HID: Hardware ID
        Name (_CID, "backlight")  // _CID: Compatible ID
        Name (_UID, Zero)  // _UID: Unique ID
        Name (_STA, 0x0B)  // _STA: Status
        Field (^RMP3, AnyAcc, NoLock, Preserve)
        {
            Offset (0x02), 
            GDID,   16, 
            Offset (0x10), 
            BAR1,   32
        }

        OperationRegion (RMB1, SystemMemory, And (BAR1, 0xFFFFFFFFFFFFFFF0), 0x000E1184)
        Field (RMB1, AnyAcc, Lock, Preserve)
        {
            Offset (0x48250), 
            LEV2,   32, 
            LEVL,   32, 
            Offset (0x70040), 
            P0BL,   32, 
            Offset (0xC2000), 
            GRAN,   32, 
            Offset (0xC8250), 
            LEVW,   32, 
            LEVX,   32, 
            Offset (0xE1180), 
            PCHL,   32
        }

        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            Store (One, Local4)
            If (CondRefOf (\RMCF.BKLT))
            {
                Store (\RMCF.BKLT, Local4)
            }

            If (LEqual (Zero, And (One, Local4)))
            {
                Return (Zero)
            }

            Store (^GDID, Local0)
            Store (Ones, Local2)
            If (CondRefOf (\RMCF.LMAX))
            {
                Store (\RMCF.LMAX, Local2)
            }

            Store (Zero, Local3)
            If (CondRefOf (\RMCF.FBTP))
            {
                Store (\RMCF.FBTP, Local3)
            }

            If (LEqual (Zero, Local3))
            {
                If (LNotEqual (Ones, Match (Package (0x10)
                                {
                                    0x010B, 
                                    0x0102, 
                                    0x0106, 
                                    0x1106, 
                                    0x1601, 
                                    0x0116, 
                                    0x0126, 
                                    0x0112, 
                                    0x0122, 
                                    0x0152, 
                                    0x0156, 
                                    0x0162, 
                                    0x0166, 
                                    0x016A, 
                                    0x46, 
                                    0x42
                                }, MEQ, Local0, MTR, Zero, Zero)))
                {
                    Store (One, Local3)
                }
                Else
                {
                    Store (0x02, Local3)
                }
            }

            If (LEqual (One, Local3))
            {
                If (LEqual (Ones, Local2))
                {
                    Store (0x0710, Local2)
                }

                ShiftRight (^LEVX, 0x10, Local1)
                If (LNot (Local1))
                {
                    Store (Local2, Local1)
                }

                If (LNotEqual (Local2, Local1))
                {
                    Divide (Multiply (^LEVL, Local2), Local1, , Local0)
                    ShiftLeft (Local2, 0x10, Local3)
                    If (LGreater (Local2, Local1))
                    {
                        Store (Local3, ^LEVX)
                        Store (Local0, ^LEVL)
                    }
                    Else
                    {
                        Store (Local0, ^LEVL)
                        Store (Local3, ^LEVX)
                    }
                }
            }
            ElseIf (LEqual (0x02, Local3))
            {
                If (LEqual (Ones, Local2))
                {
                    If (LNotEqual (Ones, Match (Package (0x16)
                                    {
                                        0x0D26, 
                                        0x0A26, 
                                        0x0D22, 
                                        0x0412, 
                                        0x0416, 
                                        0x0A16, 
                                        0x0A1E, 
                                        0x0A1E, 
                                        0x0A2E, 
                                        0x041E, 
                                        0x041A, 
                                        0x0BD1, 
                                        0x0BD2, 
                                        0x0BD3, 
                                        0x1606, 
                                        0x160E, 
                                        0x1616, 
                                        0x161E, 
                                        0x1626, 
                                        0x1622, 
                                        0x1612, 
                                        0x162B
                                    }, MEQ, Local0, MTR, Zero, Zero)))
                    {
                        Store (0x0AD9, Local2)
                    }
                    ElseIf (LNotEqual (Ones, Match (Package (0x04)
                                    {
                                        0x3E9B, 
                                        0x3EA5, 
                                        0x3E92, 
                                        0x3E91
                                    }, MEQ, Local0, MTR, Zero, Zero)))
                    {
                        Store (0xFFFF, Local2)
                    }
                    Else
                    {
                        Store (0x056C, Local2)
                    }
                }

                If (LEqual (Zero, And (0x02, Local4)))
                {
                    Store (0xC0000000, Local5)
                    If (CondRefOf (\RMCF.LEVW))
                    {
                        If (LNotEqual (Ones, \RMCF.LEVW))
                        {
                            Store (\RMCF.LEVW, Local5)
                        }
                    }

                    Store (Local5, ^LEVW)
                }

                If (And (0x04, Local4))
                {
                    If (CondRefOf (\RMCF.GRAN))
                    {
                        Store (\RMCF.GRAN, ^GRAN)
                    }
                    Else
                    {
                        Store (Zero, ^GRAN)
                    }
                }

                ShiftRight (^LEVX, 0x10, Local1)
                If (LNot (Local1))
                {
                    Store (Local2, Local1)
                }

                If (LNotEqual (Local2, Local1))
                {
                    Or (Divide (Multiply (And (^LEVX, 0xFFFF), Local2), Local1, ), ShiftLeft (Local2, 0x10), Local0)
                    Store (Local0, ^LEVX)
                }
            }

            If (LEqual (Local2, 0x0710))
            {
                Store (0x0E, _UID)
            }
            ElseIf (LEqual (Local2, 0x0AD9))
            {
                Store (0x0F, _UID)
            }
            ElseIf (LEqual (Local2, 0x056C))
            {
                Store (0x10, _UID)
            }
            ElseIf (LEqual (Local2, 0x07A1))
            {
                Store (0x11, _UID)
            }
            ElseIf (LEqual (Local2, 0x1499))
            {
                Store (0x12, _UID)
            }
            ElseIf (LEqual (Local2, 0xFFFF))
            {
                Store (0x13, _UID)
            }
            Else
            {
                Store (0x63, _UID)
            }
        }
    }
    
    // SSDT patches for brightness keys
    //
    // BRT6 Method in DSDT is renamed to BRTX. All calls to BRT6 are redirected here.
    // Credits to darkhandz http://github.com/darkhandz
    //
    External(_SB.PCI0.LPCB.PS2K, DeviceObj)
    External(_SB.PCI0.IGPU, DeviceObj)
    External(_SB.PCI0.IGPU.LCD, DeviceObj)
    
    Scope(_SB.PCI0.IGPU)
    {
        Method (BRT6, 2, NotSerialized)
        {
            If (LEqual (Arg0, One))
            {
                Notify (^LCD, 0x86)    //native code
                Notify (^^LPCB.PS2K, 0x0206) // PS2 code
                Notify (^^LPCB.PS2K, 0x0286) // PS2 code
            }

            If (And (Arg0, 0x02))
            {
                Notify (^LCD, 0x87)    //native code
                Notify (^^LPCB.PS2K, 0x0205) // PS2 code
                Notify (^^LPCB.PS2K, 0x0285) // PS2 code
            }
        }
    }
    
    // SSDT patches for deep idle
    //
    // This SSDT adds IOPMDeepIdleSupported to IOPMRootDomain
    // (found at IOService:/AppleACPIPlatformExpert/IOPMrootDomain).
    //
    // From https://pikeralpha.wordpress.com/2017/01/12/debugging-sleep-issues/
    // 
    // Credit to darkhandz https://github.com/darkhandz/XPS15-9550-Sierra
    //
    Scope (\_SB)
    {
        Method (LPS0, 0, NotSerialized)
        {
            Return (One)
        }
    }
    
    Scope (\_GPE)
    {
        Method (LXEN, 0, NotSerialized)
        {
            Return (One)
        }
    }
    
    Scope (\)
    {
        Name (SLTP, Zero)
        
        Method (_TTS, 1, NotSerialized)
        {
            Store (Arg0, SLTP)
        }
    }

    // SSDT patches for disabling discrete graphics
    //
    // Credits to rehabman for the guide 
    // https://www.tonymacx86.com/threads/guide-using-clover-to-hotpatch-acpi.200137/
    //
    External (_SB_.PCI0.PEG0.PEGP._OFF, MethodObj)

    Device(RMD1)
    {
        Name(_HID, "RMD10000")
        Method(_INI)
        {
            \_SB.PCI0.PEG0.PEGP._OFF ()
        }
    }

    // SSDT patches for DMAC
    //
    // This SSDT adds a DMA Controller to the LPCB device
    //
    // Credit to syscl:
    // https://github.com/syscl/XPS9350-macOS
    //
    External(_SB.PCI0.LPCB, DeviceObj)
    
    Scope(_SB.PCI0.LPCB)
    {
		Device (DMAC) // macOS desires DMAC credit syscl
		{
		    Name (_HID, EisaId ("PNP0200"))
		    Name (_CRS, ResourceTemplate ()
		    {
		        IO (Decode16,
		        0x0000,
		        0x0000,
		        0x01,
		        0x20,
		        )
		        IO (Decode16,
		        0x0081,
		        0x0081,
		        0x01,
		        0x11,
		        )
		        IO (Decode16,
		        0x0093,
		        0x0093,
		        0x01,
		        0x0D,
		        )
		        IO (Decode16,
		        0x00C0,
		        0x00C0,
		        0x01,
		        0x20,
		        )
		        DMA (Compatibility, NotBusMaster, Transfer8_16, )
		        {4}
		    })
		}
	}

    // SSDT patches for instant wake caused by USB
    //
    // For solving instant wake by hooking GPRW and/or UPRW
    // Credits to rehabman http://github.com/rehabman
    //
    External(YPRW, MethodObj)

    // In DSDT, native GPRW is renamed to XPRW with Clover binpatch.
    // As a result, calls to GPRW land here.
    // The purpose of this implementation is to avoid "instant wake"
    // by returning 0 in the second position (sleep state supported)
    // of the return package.
    
    Method(GPRW, 2)
    {
        If (0x6d == Arg0) { Return (Package() { 0x6d, 0, }) }
        Return (\YPRW(Arg0, Arg1))
    }

    Method(UPRW, 0)
    {
        Return (Zero)
    }

    // SSDT patches for overriding _PTS and _WAK
    //
    // Turn on the DGPU when computer goes to sleep, and turn off when computer
    // wakes from sleep.
    //
    // Credits to rehabman for the guide https://www.tonymacx86.com/threads/guide-using-clover-to-hotpatch-acpi.200137/post-1308262
    //
    External(ZPTS, MethodObj)
    External(ZWAK, MethodObj)

    External(_SB.PCI0.PEG0.PEGP._ON, MethodObj)
    External(_SB.PCI0.PEG0.PEGP._OFF, MethodObj)

    External(RMCF.DPTS, IntObj)
    External(RMCF.SHUT, IntObj)

    // In DSDT, native _PTS and _WAK are renamed ZPTS/ZWAK
    // As a result, calls to these methods land here.
    Method(_PTS, 1)
    {
        if (5 == Arg0)
        {
            // Shutdown fix, if enabled
            If (CondRefOf(\RMCF.SHUT))
            {
                If (\RMCF.SHUT & 1) { Return }
                If (\RMCF.SHUT & 2)
                {
                    OperationRegion(PMRS, SystemIO, 0x1830, 1)
                    Field(PMRS, ByteAcc, NoLock, Preserve)
                    {
                        ,4,
                        SLPE, 1,
                    }
                    // alternate shutdown fix using SLPE (mostly provided as an example)
                    // likely very specific to certain motherboards
                    Store(0, SLPE)
                    Sleep(16)
                }
            }
        }

        If (CondRefOf(\RMCF.DPTS))
        {
            If (\RMCF.DPTS)
            {
                // enable discrete graphics on sleep
                \_SB.PCI0.PEG0.PEGP._ON()
            }
        }

        // call into original _PTS method
        ZPTS(Arg0)
    }
    Method(_WAK, 1)
    {
        // Take care of bug regarding Arg0 in certain versions of OS X...
        // (starting at 10.8.5, confirmed fixed 10.10.2)
        If (Arg0 < 1 || Arg0 > 5) { Arg0 = 3 }

        // call into original _WAK method
        Local0 = ZWAK(Arg0)

        If (CondRefOf(\RMCF.DPTS))
        {
            If (\RMCF.DPTS)
            {
                // disable discrete graphics on wake
                \_SB.PCI0.PEG0.PEGP._OFF()
            }
        }

        // return value from original _WAK
        Return (Local0)
    }

    // SSDT patches for proper USB port configurations (use with USBInjectAll.kext)
    //
    // Note: Your Dell G7 might have different USB port configuration. If some
    // of your usb ports or webcam/sd card reader doesn't work then you have
    // to modify lines of code below to suit your needs.
    //
    // Look on how to do that here https://www.tonymacx86.com/threads/guide-creating-a-custom-ssdt-for-usbinjectall-kext.211311/
    //
    // Also, USB type C might not work because I don't have USB C device create proper port config.
    //
    // Credits to rehabman for the guide http://github.com/rehabman
    //
    Device(UIAC)
    {
        Name(_HID, "UIA00000")

        Name(RMCF, Package()
        {
             "8086_a36d", Package()
            {
                "port-count", Buffer() { 26, 0, 0, 0 },
                "ports", Package()
                {
                    "HS01", Package() // Left USB 2
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 1, 0, 0, 0 },
                    },
                    "HS02", Package() // Top-right USB 2
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 2, 0, 0, 0 },
                    },
                    "HS03", Package() // Bottom-right USB 2
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 3, 0, 0, 0 },
                    },
                    "HS05", Package() // Internal Webcam
                    {
                        "UsbConnector", 255,
                        "port", Buffer() { 5, 0, 0, 0 },
                    },
                    "HS06", Package() // Card Reader
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 6, 0, 0, 0 },
                    },
                    //"HS09", Package() // Goodix Fingerprint (Disabled because no use)
                    //{
                    //    "UsbConnector", 255,
                    //    "port", Buffer() { 9, 0, 0, 0 },
                    //},
                    //"HS14", Package() // Intel Bluetooth (Disabled because no use)
                    //{
                    //   "UsbConnector", 255,
                    //    "port", Buffer() { 14, 0, 0, 0 },
                    //},
                    "SS01", Package() // Left USB 3
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 17, 0, 0, 0 },
                    },
                    "SS02", Package() // Top-right USB 3
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 18, 0, 0, 0 },
                    },
                    "SS03", Package() // Bottom-right USB 3
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 19, 0, 0, 0 },
                    },
                },
            },
        })
    }

    // SSDT patches for USB power properties injection via USBX device
    //
    // Credits to rehabman for the guide
    // https://www.tonymacx86.com/threads/guide-usb-power-property-injection-for-sierra-and-later.222266/
    //
    Device(_SB.USBX)
    {
        Name(_ADR, 0)
        Method (_DSM, 4)
        {
            If (!Arg2) { Return (Buffer() { 0x03 } ) }
            Return (Package()
            {
                "kUSBSleepPortCurrentLimit", 2100,
                "kUSBSleepPowerSupply", 2600,
                "kUSBWakePortCurrentLimit", 2100,
                "kUSBWakePowerSupply", 3200,
            })
        }
    }

    // SSDT patches for simulating a version of Windows for Darwin
    //
    // Credits to rehabman http://github.com/rehabman
    //
    Method(XOSI, 1)
    {
        // All _OSI calls in DSDT are routed to XOSI...
        // XOSI simulates "Windows 2018.2" (which is Windows 10 version 1809)
        //
        // Note: According to ACPI spec, _OSI("Windows") must also return true,
        // _OSI should also return true for all previous versions of Windows.
        //
        // Source: https://docs.microsoft.com/en-us/windows-hardware/drivers/acpi/winacpi-osi
        Store(Package()
        {
            "Windows", 
            "Windows 2001", 
            "Windows 2001 SP2", 
            "Windows 2006", 
            "Windows 2006 SP1", 
            "Windows 2006.1", 
            "Windows 2009", 
            "Windows 2012", 
            "Windows 2013", 
            "Windows 2015", 
            "Windows 2016", 
            "Windows 2017", 
            "Windows 2017.2", 
            "Windows 2018",
            "Windows 2018.2"
        }, Local0)
        Return (Ones != Match(Local0, MEQ, Arg0, MTR, 0, 0))
    }

    // SSDT patches for I2C touchpad with Voodoo I2C in GPIO interrupt (disabled by default)
    //
    // WARNING: As of 06-04-2019, GPIO interrupt mode on Coffee Lake is not supported. 
    // Don't uncomment the lines of code below until Coffee Lake support arrives.
    // You can still use VoodooI2C in Polling mode, though it slightly increases 
    // cpu usage.
    //
    /*
    External (_SB_.PCI0.GPI0, DeviceObj)    
    External (_SB_.PCI0.I2C1.TPD1, DeviceObj)  
    External (_SB_.PCI0.I2C1.TPD1.SBFB, IntObj)
    External (_SB_.PCI0.I2C1.TPD1.SBFG, IntObj)  

    Scope (_SB.PCI0.GPI0)
    {
        Method (_STA, 0, NotSerialized)
        {
            Return (0x0F)
        }
    }

    Scope (_SB.PCI0.I2C1.TPD1)
    {    
        Method (_CRS, 0, Serialized)
        {       
            Return (ConcatenateResTemplate (SBFB, SBFG))
        }
    }
    */
}