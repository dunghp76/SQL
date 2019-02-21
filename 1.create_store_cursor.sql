-- --------------------------------------------------------
-- ホスト:                          mysql-test-gufu.cqnq0j3be4gt.ap-northeast-1.rds.amazonaws.com
-- サーバーのバージョン:                   5.6.34-log - MySQL Community Server (GPL)
-- サーバー OS:                      Linux
-- HeidiSQL バージョン:               10.1.0.5464
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

--  プロシージャ figo.sp_sub_set_lar_wei_product の構造をダンプしています
DELIMITER //
CREATE DEFINER=`daito_db`@`%` PROCEDURE `sp_sub_set_lar_wei_product`()
BEGIN
-- 例外処理変数宣言エリア
	DECLARE sp_name CHAR(255) DEFAULT 'sp_sub_set_lar_wei_product';
	DECLARE process_step_name CHAR(100) DEFAULT 'Start process';
	DECLARE code CHAR(5) DEFAULT '00000';
	DECLARE msg TEXT DEFAULT 'Finished';
	DECLARE rows_count INT DEFAULT 0;
	DECLARE ope_name CHAR(50);
	
-- ストアドプロシージャ変数エリア
	DECLARE m_keyword varchar(255);
	DECLARE done INT;
	DECLARE m_cursor CURSOR FOR SELECT keywork FROM master_plus.mst_len_wei_keyword;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
-- Declare exception handler for failed insert
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1
		code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
		ROLLBACK;
		CALL master_plus_sp.sp_write_logs(sp_name, process_step_name, code, msg, rows_count, ope_name);
	END;

-- 実行者名を取得する
	SET ope_name = SESSION_USER();
	
-- Begin transaction
	START TRANSACTION;
	
	OPEN m_cursor;

	checker_loop: LOOP		
		FETCH m_cursor INTO m_keyword;
		IF done = 1 THEN
			LEAVE checker_loop;
		END IF;	
		
		-- チェック商品。
		SET process_step_name = 'Update oogata flag';	
		
		UPDATE master_plus.mst_product_control as pcon
		JOIN master_plus.temp_product_code as ptemp
		ON pcon.product_code = ptemp.product_code
		JOIN master_plus.mst_product_base as pbase
		ON pcon.product_code = pbase.product_code
		SET pcon.product_oogata = 1
		
		WHERE pbase.product_name LIKE CONCAT('%', TRIM(m_keyword) , '%');
		
	END LOOP checker_loop;
	-- 
	CLOSE m_cursor;
	
	COMMIT;	
	
	SET process_step_name = 'End process';	
	
	-- Write logs --
   CALL master_plus_sp.sp_write_logs(sp_name, process_step_name, code, msg, rows_count, ope_name);   
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
