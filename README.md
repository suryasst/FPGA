# Car Park Access Control System

This repository contains the source code for a simple Finite State Machine (FSM) based car park access control system. The system is designed to manage the entry of vehicles into a car park using a password-based mechanism.

## Functionality

The system operates according to the following rules:

1. **IDLE State**: The FSM starts in the IDLE state.
2. **WAIT_PASSWORD State**: If a vehicle is detected by the front sensor, the FSM transitions to the WAIT_PASSWORD state for 4 cycles. During this state, the vehicle is prompted to input a password.
3. **RIGHT_PASS State**: If the correct password is entered, the gate is opened to allow the vehicle into the car park, and the FSM transitions to the RIGHT_PASS state. A Green LED blinks to signal successful entry.
4. **WRONG_PASS State**: If an incorrect password is entered, the FSM transitions to the WRONG_PASS state. A Red LED blinks to indicate the error, and the vehicle is prompted to enter the password again until it is correct.
5. **STOP State**: When the current vehicle enters the car park (detected by the back sensor) and there is another vehicle approaching, the FSM transitions to the STOP state. A Red LED blinks to signal the approaching vehicle to stop and enter the password.
6. After a vehicle successfully enters the car park, the FSM returns to the IDLE state to await the next vehicle.
