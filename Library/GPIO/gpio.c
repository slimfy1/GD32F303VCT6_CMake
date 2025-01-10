//
// Created by user on 10/01/2025.
//
#include "gd32f30x.h"
#include "systick.h"
#include <stdio.h>
#include "main.h"
#include "gd32f303e_eval.h"

void blink_led_gd32(void) {
	gd_eval_led_on(LED3);
	delay_1ms(500);
	gd_eval_led_off(LED3);
	delay_1ms(500);
}