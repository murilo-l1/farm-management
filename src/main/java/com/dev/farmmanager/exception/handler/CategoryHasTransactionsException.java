package com.dev.farmmanager.exception.handler;

import com.dev.farmmanager.exception.handler.message.ErrorMessage;

public class CategoryHasTransactionsException extends BadRequestException {
    public CategoryHasTransactionsException(long count) {
        super(ErrorMessage.categoryHasTransactions(count));
    }
}
