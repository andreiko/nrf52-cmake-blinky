BUILD=cmake-build-release

.PHONY: all flash reset
all: $(BUILD)/blinky.hex

$(BUILD)/blinky.hex: $(BUILD)/blinky
	arm-none-eabi-objcopy -O ihex $^ $@

flash: $(BUILD)/blinky.hex
	nrfjprog -f nrf52 --program $^ --sectorerase

reset:
	nrfjprog -f nrf52 --reset
