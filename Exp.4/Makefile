CXX = g++
CXXFLAGS = -Wall -Wextra -std=c++17

TARGET = mycp
SRC = mycp.cpp

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRC)

clean:
	rm -f $(TARGET)
