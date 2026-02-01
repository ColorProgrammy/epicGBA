/* MyGBAProject3 - GBA Game */
#include "gba.h"

int main() {
    // Set video mode 3 (bitmap) with BG2
    REG_DISPCNT = MODE_3 | BG2_ENABLE;
    
    // Video memory pointer
    u16* vram = (u16*)MEM_VRAM;
    
    // Fill screen with red
    for(int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {
        vram[i] = RGB15(31, 0, 0);
    }
    delay(1000000);
    
    // Fill screen with green
    for(int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {
        vram[i] = RGB15(0, 31, 0);
    }
    delay(1000000);
    
    // Fill screen with blue
    for(int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {
        vram[i] = RGB15(0, 0, 31);
    }
    
    // Main game loop
    while(1) {
        u16 keys = keysDown();
        
        if(keys & KEY_A) {
            for(int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {
                vram[i] = RGB15(31, 31, 0);  // Yellow
            }
        }
        
        if(keys & KEY_B) {
            for(int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {
                vram[i] = RGB15(31, 0, 31);  // Purple
            }
        }
        
        delay(10000);
    }
    
    return 0;
}
