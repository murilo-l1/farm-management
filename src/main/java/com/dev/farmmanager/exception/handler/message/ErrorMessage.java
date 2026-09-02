package com.dev.farmmanager.exception.handler.message;

public final class ErrorMessage {
    // TODO: pensar em mecanismo de i18n, mas pro projeto vai ser só português

    private ErrorMessage(){}

    public static final String USER_NOT_FOUND = "Usuário não encontrado";
    public static final String BLANK_CREDENTIALS = "Credenciais em branco";
    public static final String INVALID_CREDENTIALS = "Email ou senha incorretos";
    public static final String ALREADY_EXISTS = "Email já cadastrado";
    public static final String WRONG_PASSWORD = "Senha atual incorreta";
    
    // Payload Validation messages
    public static final String VALIDATION_FAILED = "Requisição inválida.";
    public static final String REQUIRED_NAME = "O nome é obrigatório";
    public static final String INVALID_NAME_LENGTH = "Tamanho de nome inválido";
    public static final String REQUIRED_EMAIL = "O email é obrigatório";
    public static final String INVALID_EMAIL = "Email inválido";
    public static final String REQUIRED_PASSWORD = "A senha é obrigatória";
    public static final String INVALID_PASSWORD_LENGTH = "A senha deve ter entre 8 e 100 caracteres";
    public static final String REQUIRED_PHONE = "O telefone é obrigatório";
    public static final String INVALID_PHONE_LENGTH = "O telefone deve ter entre 10 e 11 caracteres";
    public static final String POSITIVE_OR_ZERO = "O valor deve ser maior ou igual à zero";
    public static final String START_DATE_GREATER_THAN_END_DATE = "A Data de início deve ser anterior à data de fim";

    // Category
    public static final String CATEGORY_NOT_FOUND = "Categoria não encontrada";
    public static final String INVALID_COLOR = "A cor deve ser um valor hexadecimal válido";
    public static String categoryHasItems(long count) {
        return String.format("Esta categoria possui %d item(ns) e não pode ser excluída. Exclua os itens ou remova sua categoria para continuar.", count);
    }

    // Item
    public static final String ITEM_NOT_FOUND = "Item não encontrado";
    public static final String INVALID_UNITY_LENGTH = "A unidade deve ter no máximo 50 caracteres";
    public static final String INVALID_BRAND_LENGTH = "A marca deve ter no máximo 255 caracteres";

    // CropCycle
    public static final String CROP_CYCLE_NOT_FOUND = "Ciclo de cultura não encontrado";
    public static final String REQUIRED_CROP = "O tipo de cultura é obrigatório";
    public static final String INVALID_CROP_LENGTH = "A cultura deve ter no máximo 50 caracteres";
    public static final String INVALID_UNIT_LENGTH = "A unidade de medida deve ter no máximo 15 caracteres";
    public static final String REQUIRED_STATUS = "O status é obrigatório";
    public static final String REQUIRED_START_DATE = "A data de início é obrigatória";
    public static final String INVALID_MEASUREMENT_UNIT_PAIR = "Se a unidade é pés, o número de plantas deve ser informado";
    public static String cropCycleHasTransactions(long count) {
        return String.format(
                "Esta safra possui %d transação(ões) associada(s) e não pode ser excluída. " +
                        "Para encerrar sem perder o histórico financeiro, altere o status para FINALIZADO ou CANCELADO.",
                count
        );
    }


    // Transaction
    public static final String TRANSACTION_NOT_FOUND = "Transação não encontrada";
    public static final String REQUIRED_TYPE = "O tipo de transação é obrigatório";
    public static final String REQUIRED_TOTAL_VALUE = "O valor total é obrigatório";
    public static final String REQUIRED_TRANSACTION_DATE = "A data da transação é obrigatória";
    public static final String TOTAL_VALUE_INVALID_PAIR = "O valor total da transação deve ser informado ou será calculado pelos itens adicionados";
    public static final String TOTAL_VALUE_REQUIRED = "O valor da transação é obrigatório";

    //TransactionItem
    public static final String ITEM_ID_REQUIRED = "Id do item é obrigatório";
    public static final String QUANTITY_REQUIRED = "A quantidade é obrigatória";
    public static final String UNIT_PRICE_REQUIRED = "O preço unitário é obrigatório";

    // Stakeholder
    public static final String STAKEHOLDER_NOT_FOUND = "Fornecedor/comprador não encontrado";
    public static final String INVALID_CPF = "CPF inválido";
    public static final String INVALID_CNPJ = "CNPJ inválido";
    public static final String INVALID_DOCUMENT_PAIR = "Não é possível informar CPF e CNPJ simultaneamente";
    public static final String INVALID_PHONE_STAKEHOLDER_LENGTH = "O telefone deve ter no máximo 20 caracteres";
}
