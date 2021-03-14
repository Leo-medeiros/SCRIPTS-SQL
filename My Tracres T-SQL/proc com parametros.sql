exec stp_Load_all_Columns

exec stp_Load_all_Events @id = 122

exec Stp_stop @ID_trace = 2

exec Stp_Teste1 @ID_Eventos = '10,13,12,122',@ID_Colunas = '1,11,14,16,12', @ID_Col_filter = '3', @logical_operator = '0', @comparison_operator = '0', @value = '5'


SELECT *
FROM FN_TRACE_GETTABLE('D:\Bancos\estudos e testes\ProfileTrace2021.trc', DEFAULT)


