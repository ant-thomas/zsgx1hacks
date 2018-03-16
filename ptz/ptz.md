### PTZ Driver Interface

The camera implements PTZ using the `gkptz.ko` kernel driver. When loaded, this
driver exposes a device at `/dev/ptz`. By issuing ioctls to this device, PTZ
actions may be triggered. The command-line utility provided in `ptz.c` may be
used to issue such ioctls to the device. Through reverse engineering of the
`p2pcam` binary, the following commands were identified:

| ioctl request | arg0     | Action        |
| ------------- | -------- | ------------- |
|          0x64 |     0x00 | Stop          |
|          0x65 |     0x14 | Up            |
|          0x66 |     0x14 | Down          |
|          0x67 |     0x20 | Left          |
|          0x68 |     0x20 | Right         |
|          0x69 | 0x200020 | Left & Up     |
|          0x6a | 0x200020 | Left & Down   |
|          0x6b | 0x200020 | Right & Up    |
|          0x6c | 0x200020 | Right & Down  |
|          0x74 |     0xff | Calibrate PTZ |
|          0x82 |  pointer | Get Position  |
|          0x81 |          | ?             |
|          0x83 |          | ?             |
|          0x85 |          | ?             |

The `request` argument specifies which action to carry out. Additional data is
transferred through `arg0`.

#### Movement Speed

For movement commands, `arg0` specifies the speed of the movement. In `p2pcam`
this is usually set to either `0x14` or `0x20`. For simultaneous movement on
two axes, two speed values are packed into the 32-bit argument.

#### Get Position

The "Get Position" request `0x82` will write the current PTZ position to the
memory location specified in `arg0`. The following data was observed:

{{{04 01 00 00 5a}}}

The first two bytes may be interpreted as a 16-bit litte-endian integer and
represent the pan-axis (left/right). Its current value (hex: 0x0104 ; dec: 260)
represents the "straight forward" direction. Turning to the left decreases this
value, turning to the right increases it. This value ranges from 0x0 to
approximately 0x01e0.

The third and fourth byte are always zero.

The fith byte describes the tilt-axis (up/down). Its current value (hex: 0x5a ;
dec: 90) represents the "down" direction. Tilting upwards decreases the value
till it reaches 0x00.

*TODO:* Determine how many bytes are actually written to the buffer by "Get
Position".

