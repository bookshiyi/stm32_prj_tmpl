cmake_minimum_required(VERSION 3.22)
# Enable CMake support for ASM and C languages
enable_language(C ASM)
# STM32CubeMX generated symbols (macros)
set(MX_Defines_Syms
 USE_HAL_DRIVER
 STM32F407xx
 $<$<CONFIG:Debug>:DEBUG>
)


# STM32CubeMX generated include paths
set(MX_Include_Dirs
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Core/Inc
    ${CMAKE_CURRENT_SOURCE_DIR}/../../LWIP/App
    ${CMAKE_CURRENT_SOURCE_DIR}/../../LWIP/Target
    ${CMAKE_CURRENT_SOURCE_DIR}/../../USB_DEVICE/App
    ${CMAKE_CURRENT_SOURCE_DIR}/../../USB_DEVICE/Target
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LwIP/src/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LwIP/system
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32F4xx_HAL_Driver/Inc
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/STM32F4xx_HAL_Driver/Inc/Legacy
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/FreeRTOS/Source/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/BSP/Components/dp83848
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LwIP/src/include/netif/ppp
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/ST/STM32_USB_Device_Library/Core/Inc
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/ST/STM32_USB_Device_Library/Class/CDC/Inc
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/ST/STM32_USB_Device_Library/Class/MSC/Inc
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/CMSIS/Device/ST/STM32F4xx/Include
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LwIP/src/include/lwip
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LwIP/src/include/lwip/apps
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LwIP/src/include/lwip/priv
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LwIP/src/include/lwip/prot
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LwIP/src/include/netif
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LwIP/src/include/compat/posix
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LwIP/src/include/compat/posix/arpa
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LwIP/src/include/compat/posix/net
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LwIP/src/include/compat/posix/sys
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LwIP/src/include/compat/stdc
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Middlewares/Third_Party/LwIP/system/arch
    ${CMAKE_CURRENT_SOURCE_DIR}/../../Drivers/CMSIS/Include
)

# STM32CubeMX generated application sources
file( GLOB MX_Application_Src
    # ${CMAKE_SOURCE_DIR}/Core/Src/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../../startup_stm32f407xx.s
)

##################### User includes  #####################
set(User_Include_Dirs
    ${CMAKE_SOURCE_DIR}/App/Inc
    ${CMAKE_SOURCE_DIR}/coreMQTT
)
##################### Application  sources #####################
file(GLOB App_Src
    ${CMAKE_SOURCE_DIR}/App/Src/*.c
)
##################### coreMQTT  sources #####################
file(GLOB CoreMQTT_Src
    ${CMAKE_SOURCE_DIR}/Middlewares/Third_Party/coreMQTT/source/*.c
)

# Link directories setup
set(MX_LINK_DIRS

)
# Project static libraries
set(MX_LINK_LIBS
    App
    # CoreMQTT
)

# Interface library for includes and symbols
add_library(user INTERFACE)
target_include_directories(user INTERFACE ${MX_Include_Dirs}
                                          ${User_Include_Dirs})
target_compile_definitions(user INTERFACE ${MX_Defines_Syms})

##################### Create App static library #####################
add_library(App OBJECT)
target_sources(App PRIVATE ${App_Src})
target_link_libraries(App PUBLIC user)

##################### Create CoreMQTT static library #####################
add_library(CoreMQTT OBJECT)
target_sources(CoreMQTT PRIVATE ${CoreMQTT_Src})
target_link_libraries(CoreMQTT PUBLIC user)

# Add STM32CubeMX generated application sources to the project
target_sources(${CMAKE_PROJECT_NAME} PRIVATE ${MX_Application_Src})

# Link directories setup
target_link_directories(${CMAKE_PROJECT_NAME} PRIVATE ${MX_LINK_DIRS})

# Add libraries to the project
target_link_libraries(${CMAKE_PROJECT_NAME} ${MX_LINK_LIBS})

# Add the map file to the list of files to be removed with 'clean' target
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES ADDITIONAL_CLEAN_FILES ${CMAKE_PROJECT_NAME}.map)

# Validate that STM32CubeMX code is compatible with C standard
if((CMAKE_C_STANDARD EQUAL 90) OR (CMAKE_C_STANDARD EQUAL 99))
    message(ERROR "Generated code requires C11 or higher")
endif()
