#ifndef GBA_H
#define GBA_H

// Basic types
typedef unsigned char   u8;
typedef unsigned short  u16;
typedef unsigned int    u32;

// Video modes
#define MODE_0          0x0000
#define MODE_1          0x0001
#define MODE_2          0x0002
#define MODE_3          0x0003
#define MODE_4          0x0004
#define MODE_5          0x0005

// Background flags
#define BG0_ENABLE      0x0100
#define BG1_ENABLE      0x0200
#define BG2_ENABLE      0x0400
#define BG3_ENABLE      0x0800
#define OBJ_ENABLE      0x1000

// Memory addresses
#define MEM_VRAM        0x06000000
#define MEM_OAM         0x07000000
#define MEM_PAL         0x05000000

// Registers
#define REG_DISPCNT     *(volatile u32*)0x04000000
#define REG_KEYINPUT    *(volatile u16*)0x04000130

// Screen size
#define SCREEN_WIDTH    240
#define SCREEN_HEIGHT   160

// Colors (RGB5: 5 bits per component)
#define RGB15(r,g,b)    ((r) | ((g) << 5) | ((b) << 10))

// Keys
#define KEY_A           0x0001
#define KEY_B           0x0002
#define KEY_SELECT      0x0004
#define KEY_START       0x0008
#define KEY_RIGHT       0x0010
#define KEY_LEFT        0x0020
#define KEY_UP          0x0040
#define KEY_DOWN        0x0080
#define KEY_R           0x0100
#define KEY_L           0x0200

// Delay function
static inline void delay(int count) {
    for(volatile int i = 0; i < count; i++);
}

// Key functions
static inline u16 keysDown() { 
    return ~REG_KEYINPUT & 0x03FF; 
}

static inline u16 keysHeld() { 
    return ~REG_KEYINPUT & 0x03FF; 
}

#endif // GBA_H
