/**
  ******************************************************************************
  * @file      startup_gd32f303_hd.s
  * @author    MCD Application Team
  * @brief     STM32F407xx Devices vector table for GCC based toolchains.
  *            This module performs:
  *                - Set the initial SP
  *                - Set the initial PC == Reset_Handler,
  *                - Set the vector table entries with the exceptions ISR address
  *                - Branches to main in the C library (which eventually
  *                  calls main()).
  *            After Reset the Cortex-M4 processor is in Thread mode,
  *            priority is Privileged, and the Stack is set to Main.
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2017 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */

  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb

.global  g_pfnVectors
.global  Default_Handler

/* start address for the initialization values of the .data section.
defined in linker script */
.word  _sidata
/* start address for the .data section. defined in linker script */
.word  _sdata
/* end address for the .data section. defined in linker script */
.word  _edata
/* start address for the .bss section. defined in linker script */
.word  _sbss
/* end address for the .bss section. defined in linker script */
.word  _ebss
/* stack used for SystemInit_ExtMemCtl; always internal RAM used */

/**
 * @brief  This is the code that gets called when the processor first
 *          starts execution following a reset event. Only the absolutely
 *          necessary set is performed, after which the application
 *          supplied main() routine is called.
 * @param  None
 * @retval : None
*/

    .section  .text.Reset_Handler
  .weak  Reset_Handler
  .type  Reset_Handler, %function
Reset_Handler:
  ldr   sp, =_estack     /* set stack pointer */

/* Call the clock system initialization function.*/
  bl  SystemInit

/* Copy the data segment initializers from flash to SRAM */
  ldr r0, =_sdata
  ldr r1, =_edata
  ldr r2, =_sidata
  movs r3, #0
  b LoopCopyDataInit

CopyDataInit:
  ldr r4, [r2, r3]
  str r4, [r0, r3]
  adds r3, r3, #4

LoopCopyDataInit:
  adds r4, r0, r3
  cmp r4, r1
  bcc CopyDataInit

/* Zero fill the bss segment. */
  ldr r2, =_sbss
  ldr r4, =_ebss
  movs r3, #0
  b LoopFillZerobss

FillZerobss:
  str  r3, [r2]
  adds r2, r2, #4

LoopFillZerobss:
  cmp r2, r4
  bcc FillZerobss

/* Call static constructors */
    bl __libc_init_array
/* Call the application's entry point.*/
  bl  main
  bx  lr
.size  Reset_Handler, .-Reset_Handler

/**
 * @brief  This is the code that gets called when the processor receives an
 *         unexpected interrupt.  This simply enters an infinite loop, preserving
 *         the system state for examination by a debugger.
 * @param  None
 * @retval None
*/
    .section  .text.Default_Handler,"ax",%progbits
Default_Handler:
Infinite_Loop:
  b  Infinite_Loop
  .size  Default_Handler, .-Default_Handler
/******************************************************************************
*
* The minimal vector table for a Cortex M4. Note that the proper constructs
* must be placed on this to ensure that it ends up at physical address
* 0x0000.0000.
*
*******************************************************************************/
   .section  .isr_vector,"a",%progbits
  .type  g_pfnVectors, %object


g_pfnVectors:
 .word  _estack
 .word  Reset_Handler
 .word  NMI_Handler
 .word  HardFault_Handler
 .word  MemManage_Handler
 .word  BusFault_Handler
 .word  UsageFault_Handler
 .word  0
 .word  0
 .word  0
 .word  0
 .word  SVC_Handler
 .word  DebugMon_Handler
 .word  0
 .word  PendSV_Handler
 .word  SysTick_Handler

  /* External Interrupts */
 .word  WWDGT_IRQHandler                    /* Window WatchDog              */
 .word  LVD_IRQHandler                      /* LVD through EXTI Line detect */
 .word  TAMPER_IRQHandler                   /* Tamper through EXTI Line detect */
 .word  RTC_IRQHandler                      /* RTC through EXTI Line        */
 .word  FMC_IRQHandler                      /* FMC                          */
 .word  RCU_CTC_IRQHandler                  /* RCU and CTC                  */
 .word  EXTI0_IRQHandler                    /* EXTI Line 0                  */
 .word  EXTI1_IRQHandler                    /* EXTI Line 1                  */
 .word  EXTI2_IRQHandler                    /* EXTI Line 2                  */
 .word  EXTI3_IRQHandler                    /* EXTI Line 3                  */
 .word  EXTI4_IRQHandler                    /* EXTI Line 4                  */
 .word  DMA0_Channel0_IRQHandler            /* DMA0 Channel0                */
 .word  DMA0_Channel1_IRQHandler            /* DMA0 Channel1                */
 .word  DMA0_Channel2_IRQHandler            /* DMA0 Channel2                */
 .word  DMA0_Channel3_IRQHandler            /* DMA0 Channel3                */
 .word  DMA0_Channel4_IRQHandler            /* DMA0 Channel4                */
 .word  DMA0_Channel5_IRQHandler            /* DMA0 Channel5                */
 .word  DMA0_Channel6_IRQHandler            /* DMA0 Channel6                */
 .word  ADC0_1_IRQHandler                   /* ADC0 and ADC1                */
 .word  USBD_HP_CAN0_TX_IRQHandler          /* USBD HP and CAN0 TX          */
 .word  USBD_LP_CAN0_RX0_IRQHandler         /* USBD LP and CAN0 RX0         */
 .word  CAN0_RX1_IRQHandler                 /* CAN0 RX1                     */
 .word  CAN0_EWMC_IRQHandler                /* CAN0 EWMC                    */
 .word  EXTI5_9_IRQHandler                  /* EXTI5 to EXTI9               */
 .word  TIMER0_BRK_IRQHandler               /* TIMER0 Break                 */
 .word  TIMER0_UP_IRQHandler                /* TIMER0 Update                */
 .word  TIMER0_TRG_CMT_IRQHandler           /* TIMER0 Trigger and Communication */
 .word  TIMER0_Channel_IRQHandler           /* TIMER0 Channel Capture Compare */
 .word  TIMER1_IRQHandler                   /* TIMER1                       */
 .word  TIMER2_IRQHandler                   /* TIMER2                       */
 .word  TIMER3_IRQHandler                   /* TIMER3                       */
 .word  I2C0_EV_IRQHandler                  /* I2C0 Event                   */
 .word  I2C0_ER_IRQHandler                  /* I2C0 Error                   */
 .word  I2C1_EV_IRQHandler                  /* I2C1 Event                   */
 .word  I2C1_ER_IRQHandler                  /* I2C1 Error                   */
 .word  SPI0_IRQHandler                     /* SPI0                         */
 .word  SPI1_IRQHandler                     /* SPI1                         */
 .word  USART0_IRQHandler                   /* USART0                       */
 .word  USART1_IRQHandler                   /* USART1                       */
 .word  USART2_IRQHandler                   /* USART2                       */
 .word  EXTI10_15_IRQHandler                /* EXTI10 to EXTI15             */
 .word  RTC_Alarm_IRQHandler                /* RTC Alarm                    */
 .word  USBD_WKUP_IRQHandler                /* USBD Wakeup                  */
 .word  TIMER7_BRK_IRQHandler               /* TIMER7 Break                 */
 .word  TIMER7_UP_IRQHandler                /* TIMER7 Update                */
 .word  TIMER7_TRG_CMT_IRQHandler           /* TIMER7 Trigger and Communication */
 .word  TIMER7_Channel_IRQHandler           /* TIMER7 Channel Capture Compare */
 .word  ADC2_IRQHandler                     /* ADC2                         */
 .word  EXMC_IRQHandler                     /* EXMC                         */
 .word  SDIO_IRQHandler                     /* SDIO                         */
 .word  TIMER4_IRQHandler                   /* TIMER4                       */
 .word  SPI2_IRQHandler                     /* SPI2                         */
 .word  UART3_IRQHandler                    /* UART3                        */
 .word  UART4_IRQHandler                    /* UART4                        */
 .word  TIMER5_IRQHandler                   /* TIMER5                       */
 .word  TIMER6_IRQHandler                   /* TIMER6                       */
 .word  DMA1_Channel0_IRQHandler            /* DMA1 Channel0                */
 .word  DMA1_Channel1_IRQHandler            /* DMA1 Channel1                */
 .word  DMA1_Channel2_IRQHandler            /* DMA1 Channel2                */
 .word  DMA1_Channel3_4_IRQHandler          /* DMA1 Channel3 and Channel4   */


  .size  g_pfnVectors, .-g_pfnVectors

/*******************************************************************************
*
* Provide weak aliases for each Exception handler to the Default_Handler.
* As they are weak aliases, any function with the same name will override
* this definition.
*
*******************************************************************************/
.weak      NMI_Handler
.thumb_set NMI_Handler,Default_Handler
  
.weak      HardFault_Handler
.thumb_set HardFault_Handler,Default_Handler
  
.weak      MemManage_Handler
.thumb_set MemManage_Handler,Default_Handler
  
.weak      BusFault_Handler
.thumb_set BusFault_Handler,Default_Handler

.weak      UsageFault_Handler
.thumb_set UsageFault_Handler,Default_Handler

.weak      SVC_Handler
.thumb_set SVC_Handler,Default_Handler

.weak      DebugMon_Handler
.thumb_set DebugMon_Handler,Default_Handler

.weak      PendSV_Handler
.thumb_set PendSV_Handler,Default_Handler

.weak      SysTick_Handler
.thumb_set SysTick_Handler,Default_Handler        
   
.weak WWDGT_IRQHandler
.thumb_set WWDGT_IRQHandler,Default_Handler

.weak LVD_IRQHandler
.thumb_set LVD_IRQHandler,Default_Handler

.weak TAMPER_IRQHandler
.thumb_set TAMPER_IRQHandler,Default_Handler

.weak RTC_IRQHandler
.thumb_set RTC_IRQHandler,Default_Handler

.weak FMC_IRQHandler
.thumb_set FMC_IRQHandler,Default_Handler

.weak RCU_CTC_IRQHandler
.thumb_set RCU_CTC_IRQHandler,Default_Handler

.weak EXTI0_IRQHandler
.thumb_set EXTI0_IRQHandler,Default_Handler

.weak EXTI1_IRQHandler
.thumb_set EXTI1_IRQHandler,Default_Handler

.weak EXTI2_IRQHandler
.thumb_set EXTI2_IRQHandler,Default_Handler

.weak EXTI3_IRQHandler
.thumb_set EXTI3_IRQHandler,Default_Handler

.weak EXTI4_IRQHandler
.thumb_set EXTI4_IRQHandler,Default_Handler

.weak DMA0_Channel0_IRQHandler
.thumb_set DMA0_Channel0_IRQHandler,Default_Handler

.weak DMA0_Channel1_IRQHandler
.thumb_set DMA0_Channel1_IRQHandler,Default_Handler

.weak DMA0_Channel2_IRQHandler
.thumb_set DMA0_Channel2_IRQHandler,Default_Handler

.weak DMA0_Channel3_IRQHandler
.thumb_set DMA0_Channel3_IRQHandler,Default_Handler

.weak DMA0_Channel4_IRQHandler
.thumb_set DMA0_Channel4_IRQHandler,Default_Handler

.weak DMA0_Channel5_IRQHandler
.thumb_set DMA0_Channel5_IRQHandler,Default_Handler

.weak DMA0_Channel6_IRQHandler
.thumb_set DMA0_Channel6_IRQHandler,Default_Handler

.weak ADC0_1_IRQHandler
.thumb_set ADC0_1_IRQHandler,Default_Handler

.weak USBD_HP_CAN0_TX_IRQHandler
.thumb_set USBD_HP_CAN0_TX_IRQHandler,Default_Handler

.weak USBD_LP_CAN0_RX0_IRQHandler
.thumb_set USBD_LP_CAN0_RX0_IRQHandler,Default_Handler

.weak CAN0_RX1_IRQHandler
.thumb_set CAN0_RX1_IRQHandler,Default_Handler

.weak CAN0_EWMC_IRQHandler
.thumb_set CAN0_EWMC_IRQHandler,Default_Handler

.weak EXTI5_9_IRQHandler
.thumb_set EXTI5_9_IRQHandler,Default_Handler

.weak TIMER0_BRK_IRQHandler
.thumb_set TIMER0_BRK_IRQHandler,Default_Handler

.weak TIMER0_UP_IRQHandler
.thumb_set TIMER0_UP_IRQHandler,Default_Handler

.weak TIMER0_TRG_CMT_IRQHandler
.thumb_set TIMER0_TRG_CMT_IRQHandler,Default_Handler

.weak TIMER0_Channel_IRQHandler
.thumb_set TIMER0_Channel_IRQHandler,Default_Handler

.weak TIMER1_IRQHandler
.thumb_set TIMER1_IRQHandler,Default_Handler

.weak TIMER2_IRQHandler
.thumb_set TIMER2_IRQHandler,Default_Handler

.weak TIMER3_IRQHandler
.thumb_set TIMER3_IRQHandler,Default_Handler

.weak I2C0_EV_IRQHandler
.thumb_set I2C0_EV_IRQHandler,Default_Handler

.weak I2C0_ER_IRQHandler
.thumb_set I2C0_ER_IRQHandler,Default_Handler

.weak I2C1_EV_IRQHandler
.thumb_set I2C1_EV_IRQHandler,Default_Handler

.weak I2C1_ER_IRQHandler
.thumb_set I2C1_ER_IRQHandler,Default_Handler

.weak SPI0_IRQHandler
.thumb_set SPI0_IRQHandler,Default_Handler

.weak SPI1_IRQHandler
.thumb_set SPI1_IRQHandler,Default_Handler

.weak USART0_IRQHandler
.thumb_set USART0_IRQHandler,Default_Handler

.weak USART1_IRQHandler
.thumb_set USART1_IRQHandler,Default_Handler

.weak USART2_IRQHandler
.thumb_set USART2_IRQHandler,Default_Handler

.weak EXTI10_15_IRQHandler
.thumb_set EXTI10_15_IRQHandler,Default_Handler

.weak RTC_Alarm_IRQHandler
.thumb_set RTC_Alarm_IRQHandler,Default_Handler

.weak USBD_WKUP_IRQHandler
.thumb_set USBD_WKUP_IRQHandler,Default_Handler

.weak TIMER7_BRK_IRQHandler
.thumb_set TIMER7_BRK_IRQHandler,Default_Handler

.weak TIMER7_UP_IRQHandler
.thumb_set TIMER7_UP_IRQHandler,Default_Handler

.weak TIMER7_TRG_CMT_IRQHandler
.thumb_set TIMER7_TRG_CMT_IRQHandler,Default_Handler

.weak TIMER7_Channel_IRQHandler
.thumb_set TIMER7_Channel_IRQHandler,Default_Handler

.weak ADC2_IRQHandler
.thumb_set ADC2_IRQHandler,Default_Handler

.weak EXMC_IRQHandler
.thumb_set EXMC_IRQHandler,Default_Handler

.weak SDIO_IRQHandler
.thumb_set SDIO_IRQHandler,Default_Handler

.weak TIMER4_IRQHandler
.thumb_set TIMER4_IRQHandler,Default_Handler

.weak SPI2_IRQHandler
.thumb_set SPI2_IRQHandler,Default_Handler

.weak UART3_IRQHandler
.thumb_set UART3_IRQHandler,Default_Handler

.weak UART4_IRQHandler
.thumb_set UART4_IRQHandler,Default_Handler

.weak TIMER5_IRQHandler
.thumb_set TIMER5_IRQHandler,Default_Handler

.weak TIMER6_IRQHandler
.thumb_set TIMER6_IRQHandler,Default_Handler

.weak DMA1_Channel0_IRQHandler
.thumb_set DMA1_Channel0_IRQHandler,Default_Handler

.weak DMA1_Channel1_IRQHandler
.thumb_set DMA1_Channel1_IRQHandler,Default_Handler

.weak DMA1_Channel2_IRQHandler
.thumb_set DMA1_Channel2_IRQHandler,Default_Handler

.weak DMA1_Channel3_4_IRQHandler
.thumb_set DMA1_Channel3_4_IRQHandler,Default_Handler

