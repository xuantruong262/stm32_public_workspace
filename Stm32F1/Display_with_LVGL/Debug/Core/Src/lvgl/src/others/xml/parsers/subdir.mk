################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_arc_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_bar_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_button_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_buttonmatrix_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_calendar_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_canvas_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_chart_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_checkbox_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_dropdown_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_image_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_keyboard_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_label_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_obj_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_roller_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_scale_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_slider_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_spangroup_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_table_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_tabview_parser.c \
../Core/Src/lvgl/src/others/xml/parsers/lv_xml_textarea_parser.c 

OBJS += \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_arc_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_bar_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_button_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_buttonmatrix_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_calendar_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_canvas_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_chart_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_checkbox_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_dropdown_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_image_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_keyboard_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_label_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_obj_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_roller_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_scale_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_slider_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_spangroup_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_table_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_tabview_parser.o \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_textarea_parser.o 

C_DEPS += \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_arc_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_bar_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_button_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_buttonmatrix_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_calendar_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_canvas_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_chart_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_checkbox_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_dropdown_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_image_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_keyboard_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_label_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_obj_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_roller_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_scale_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_slider_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_spangroup_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_table_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_tabview_parser.d \
./Core/Src/lvgl/src/others/xml/parsers/lv_xml_textarea_parser.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/lvgl/src/others/xml/parsers/%.o Core/Src/lvgl/src/others/xml/parsers/%.su Core/Src/lvgl/src/others/xml/parsers/%.cyclo: ../Core/Src/lvgl/src/others/xml/parsers/%.c Core/Src/lvgl/src/others/xml/parsers/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DLV_CONF_INCLUDE_SIMPLE -DLV_LVGL_H_INCLUDE_SIMPLE -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../FATFS/Target -I../FATFS/App -I../Core/Src/lvgl -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Middlewares/Third_Party/FatFs/src -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src-2f-lvgl-2f-src-2f-others-2f-xml-2f-parsers

clean-Core-2f-Src-2f-lvgl-2f-src-2f-others-2f-xml-2f-parsers:
	-$(RM) ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_arc_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_arc_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_arc_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_arc_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_bar_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_bar_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_bar_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_bar_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_button_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_button_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_button_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_button_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_buttonmatrix_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_buttonmatrix_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_buttonmatrix_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_buttonmatrix_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_calendar_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_calendar_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_calendar_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_calendar_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_canvas_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_canvas_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_canvas_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_canvas_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_chart_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_chart_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_chart_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_chart_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_checkbox_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_checkbox_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_checkbox_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_checkbox_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_dropdown_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_dropdown_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_dropdown_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_dropdown_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_image_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_image_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_image_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_image_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_keyboard_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_keyboard_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_keyboard_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_keyboard_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_label_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_label_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_label_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_label_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_obj_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_obj_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_obj_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_obj_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_roller_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_roller_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_roller_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_roller_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_scale_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_scale_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_scale_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_scale_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_slider_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_slider_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_slider_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_slider_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_spangroup_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_spangroup_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_spangroup_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_spangroup_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_table_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_table_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_table_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_table_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_tabview_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_tabview_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_tabview_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_tabview_parser.su ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_textarea_parser.cyclo ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_textarea_parser.d ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_textarea_parser.o ./Core/Src/lvgl/src/others/xml/parsers/lv_xml_textarea_parser.su

.PHONY: clean-Core-2f-Src-2f-lvgl-2f-src-2f-others-2f-xml-2f-parsers

