TARGET = stage2

NASM = nasm

ifneq ($(filter $(FW), 1000 1001 1050 1100),)
NASMFLAGS = -DFIRMWARE=$(FW)
else
$(error "Invalid firmware")
endif

all: $(TARGET)

%: %.nasm
	$(NASM) $(NASMFLAGS) -f bin $^

clean:
	@rm -f $(TARGET)
