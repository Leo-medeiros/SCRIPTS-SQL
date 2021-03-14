-- executar em uma sessão


use Estudo


BEGIN TRANSACTION

INSERT INTO tbl_deadlock values (1,'Teste 1')

-- session 2
/*
use Estudo
go
BEGIN TRAN
INSERT INTO tbl_deadlock values (2,'Teste 2')
DELETE  tbl_deadlock
*/



-- session 1
delete tbl_deadlock
--comit
rollback

EXEC stp_DeadlockExec1

-- sessao 2
exec stp_DeadlockExec2

