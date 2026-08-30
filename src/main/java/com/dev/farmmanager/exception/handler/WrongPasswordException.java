package com.dev.farmmanager.exception.handler;

import com.dev.farmmanager.exception.handler.message.ErrorMessage;

public class WrongPasswordException extends BadRequestException {
    public WrongPasswordException() {
        super(ErrorMessage.WRONG_PASSWORD);
    }
}
