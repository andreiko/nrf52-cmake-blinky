BUILD=cmake-build-release

.PHONY: all flash reset erase

all: $(BUILD)/blinky

$(BUILD)/blinky:
	make -C $(BUILD) blinky

$(BUILD)/blinky.hex: $(BUILD)/blinky
	arm-none-eabi-objcopy -O ihex $^ $@

flash: $(BUILD)/blinky.hex
	nrfjprog -f nrf52 --program $^ --sectorerase

reset:
	nrfjprog -f nrf52 --reset

erase:
	nrfjprog -f nrf52 -e
