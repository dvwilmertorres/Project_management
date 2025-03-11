---------------------------- Consulta de bloqueos
SELECT blocking_session_id, wait_duration_ms, session_id
FROM sys.dm_os_waiting_tasks
WHERE blocking_session_id IS NOT NULL

SELECT t.text
FROM sys.dm_exec_connections c
CROSS APPLY sys.dm_exec_sql_text (c.most_recent_sql_handle) t
WHERE c.session_id = 38;

SELECT request_session_id sessionid,
 resource_type type,
 resource_database_id dbid,
 OBJECT_NAME(resource_associated_entity_id, resource_database_id) objectname,
 request_mode rmode,
 request_status rstatus
FROM sys.dm_tran_locks
WHERE resource_type IN ('DATABASE', 'OBJECT')

exec sp_lock

select * from sys.dm_tran_locks


-- TOP 20 SQLS De mayor ejecución

SELECT DISTINCT TOP 20

est.TEXT AS QUERY ,

Db_name(dbid),

eqs.execution_count AS EXEC_CNT,

eqs.max_elapsed_time AS MAX_ELAPSED_TIME,

ISNULL(eqs.total_elapsed_time / NULLIF(eqs.execution_count,0), 0) AS AVG_ELAPSED_TIME,

eqs.creation_time AS CREATION_TIME,

ISNULL(eqs.execution_count / NULLIF(DATEDIFF(s, eqs.creation_time, GETDATE()),0), 0) AS EXEC_PER_SECOND,

total_physical_reads AS AGG_PHYSICAL_READS

FROM sys.dm_exec_query_stats eqs

CROSS APPLY sys.dm_exec_sql_text( eqs.sql_handle ) est

ORDER BY

eqs.max_elapsed_time DESC

------------------- BLOQUEOS

SELECT * FROM sys.sysprocesses WHERE blocked <> 0;
SELECT * FROM sys.sysprocesses WHERE spid IN (SELECT blocked FROM sys.sysprocesses where blocked <> 0);

------- ---identifying page locks with sys.dm_db_index_operational_stats

SELECT      TOP 10

OBJECT_NAME(OBJECT_ID, database_id) OBJ_NAME,

index_id,

page_lock_wait_count,

page_lock_wait_in_ms

FROM sys.dm_db_index_operational_stats (DB_ID(), NULL, NULL, NULL)

ORDER BY page_lock_wait_in_ms DESC

-------------------------------- TOP 5 SQLS MAS COSTOSOS

SELECT TOP 5

t.text as 'SQL Text',

st.execution_count ,

ISNULL( st.total_elapsed_time / st.execution_count, 0 ) as 'AVG Excecution Time',

st.total_worker_time / st.execution_count as 'AVG Worker Time',

st.total_worker_time,

st.max_logical_reads,

st.max_logical_writes,

st.creation_time,

ISNULL( st.execution_count / DATEDIFF( second, st.creation_time, getdate()), 0 ) as 'Calls Per Second'

FROM sys.dm_exec_query_stats st

CROSS APPLY sys.dm_exec_sql_text( st.sql_handle )  t

ORDER BY

st.total_elapsed_time DESC

------------------------- Buscar bloqueos

SELECT
db.name DBName,
tl.request_session_id,
wt.blocking_session_id,
OBJECT_NAME(p.OBJECT_ID) BlockedObjectName,
tl.resource_type,
h1.TEXT AS RequestingText,
h2.TEXT AS BlockingTest,
tl.request_mode
FROM sys.dm_tran_locks AS tl
INNER JOIN sys.databases db ON db.database_id = tl.resource_database_id
INNER JOIN sys.dm_os_waiting_tasks AS wt ON tl.lock_owner_address = wt.resource_address
INNER JOIN sys.partitions AS p ON p.hobt_id = tl.resource_associated_entity_id
INNER JOIN sys.dm_exec_connections ec1 ON ec1.session_id = tl.request_session_id
INNER JOIN sys.dm_exec_connections ec2 ON ec2.session_id = wt.blocking_session_id
CROSS APPLY sys.dm_exec_sql_text(ec1.most_recent_sql_handle) AS h1
CROSS APPLY sys.dm_exec_sql_text(ec2.most_recent_sql_handle) AS h2
GO

---------------------- Finding the user who running the query in the server

SELECT
s.session_id AS SessionID,
 s.login_time AS LoginTime,
 s.[host_name] AS HostName,
 s.[program_name] AS ProgramName,
 s.login_name AS LoginName,
 s.[status] AS SessionStatus,
 st.text AS SQLText,
 (s.cpu_time / 1000) AS CPUTimeInSec,
 (s.memory_usage * 8) AS MemoryUsageKB,
 (CAST(s.total_scheduled_time AS FLOAT) / 1000) AS TotalScheduledTimeInSec,
 (CAST(s.total_elapsed_time AS FLOAT) / 1000) AS ElapsedTimeInSec,
 s.reads AS ReadsThisSession,
 s.writes AS WritesThisSession,
 s.logical_reads AS LogicalReads,
 CASE s.transaction_isolation_level
 WHEN 0 THEN 'Unspecified'
 WHEN 1 THEN 'ReadUncommitted'
 WHEN 2 THEN 'ReadCommitted'
 WHEN 3 THEN 'Repeatable'
 WHEN 4 THEN 'Serializable'
 WHEN 5 THEN 'Snapshot'
 END AS TransactionIsolationLevel,
 s.row_count AS RowsReturnedSoFar,
 c.net_transport AS ConnectionProtocol,
 c.num_reads AS PacketReadsThisConnection,
 c.num_writes AS PacketWritesThisConnection,
 c.client_net_address AS RemoteHostIP,
 c.local_net_address AS LocalConnectionIP
 FROM sys.dm_exec_sessions s INNER JOIN sys.dm_exec_connections c
 ON s.session_id = c.session_id
 CROSS APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) AS st
 WHERE s.is_user_process = 1 and [status]='running'
 ORDER BY ElapsedTimeInSec,LoginTime DESC
 
 --Query which has taken more time for executing
      
      SELECT TOP 10 obj.name, max_logical_reads, max_elapsed_time
FROM sys.dm_exec_query_stats a
CROSS APPLY sys.dm_exec_sql_text(sql_handle) hnd
INNER JOIN sys.sysobjects obj on hnd.objectid = obj.id

ORDER BY max_logical_reads DESC

------- Querys costosos

--List expensive queries

DECLARE @MinExecutions int;
SET @MinExecutions = 5

SELECT EQS.total_worker_time AS TotalWorkerTime
      ,EQS.total_logical_reads + EQS.total_logical_writes AS TotalLogicalIO
      ,EQS.execution_count As ExeCnt
      ,EQS.last_execution_time AS LastUsage
      ,EQS.total_worker_time / EQS.execution_count as AvgCPUTimeMiS
      ,(EQS.total_logical_reads + EQS.total_logical_writes) / EQS.execution_count 
       AS AvgLogicalIO
      ,DB.name AS DatabaseName
      ,SUBSTRING(EST.text
                ,1 + EQS.statement_start_offset / 2
                ,(CASE WHEN EQS.statement_end_offset = -1 
                       THEN LEN(convert(nvarchar(max), EST.text)) * 2 
                       ELSE EQS.statement_end_offset END 
                 - EQS.statement_start_offset) / 2
                ) AS SqlStatement
      -- Optional with Query plan; remove comment to show, but then the query takes !!much longer time!!
      --,EQP.[query_plan] AS [QueryPlan]
FROM sys.dm_exec_query_stats AS EQS
     CROSS APPLY sys.dm_exec_sql_text(EQS.sql_handle) AS EST
     CROSS APPLY sys.dm_exec_query_plan(EQS.plan_handle) AS EQP
     LEFT JOIN sys.databases AS DB
         ON EST.dbid = DB.database_id     
WHERE EQS.execution_count > @MinExecutions
      AND EQS.last_execution_time > DATEDIFF(MONTH, -1, GETDATE())
ORDER BY AvgLogicalIo DESC
        ,AvgCPUTimeMiS DESC
		
--------------------- REFRESCAR INDICES Y ESTADISTICAS

USE DB_TSIGO_TST --Enter the name of the database you want to reindex 
 
DECLARE @TableName varchar(255) 
DECLARE TableCursor CURSOR FOR 
 
SELECT table_name FROM information_schema.tables 
 
WHERE table_type = 'base table' 
 
  
 
OPEN TableCursor 
 
  
 
FETCH NEXT FROM TableCursor INTO @TableName 
 
WHILE @@FETCH_STATUS = 0 
 
BEGIN 
 
DBCC DBREINDEX(@TableName,' ',90) 
 
FETCH NEXT FROM TableCursor INTO @TableName 
 
END 
 
  
 
CLOSE TableCursor 
 
  
 
DEALLOCATE TableCursor

----- CONSULTAR ULTIMA ACTUALIZACION DE ESTADISTICAS E INDICES

SELECT name AS Stats,
STATS_DATE(object_id, stats_id) AS LastStatsUpdate
FROM sys.stats
WHERE object_id = OBJECT_ID('dbo.alert_warehouse')
and left(name,4)!='_WA_';

SELECT name AS stats_name,   
    STATS_DATE(object_id, stats_id) AS statistics_update_date  
FROM sys.stats   
WHERE object_id = OBJECT_ID('Person.Address');  

-------------- ESTADO DE LOS INDICES

SELECT o.name Object_Name, 
       SCHEMA_NAME(o.schema_id) Schema_name, 
       i.name Index_name, 
       i.Type_Desc, 
       s.user_seeks, 
       s.user_scans, 
       s.user_lookups, 
       s.user_updates  
FROM sys.objects AS o 
     JOIN sys.indexes AS i 
ON o.object_id = i.object_id 
     JOIN 
  sys.dm_db_index_usage_stats AS s    
ON i.object_id = s.object_id   
  AND i.index_id = s.index_id 
WHERE  o.type = 'u' 
-- Clustered and Non-Clustered indexes 
  AND i.type IN (1, 2) 
-- Indexes that have been updated by not used 
  AND(s.user_seeks >= 0 or s.user_scans >= 0 or s.user_lookups >= 0 );
  
------------------------------- NUMERO DE REGISTROS POR TABLA

select si.rows as 'filas', SO.Name as Tabla, SI.name as 'Index', SFG.groupname as 'Filegroup'
from sysobjects as SO 
    join sysindexes as SI on SO.Id = SI.id 
    join sysfilegroups as SFG on SI.GroupId = SFG.GroupId
order by si.rows desc, SO.Name , SI.name, SFG.GroupName;

------------------------------- INDICES SUGERIDOS NO OPTIMIZADOS

SELECT  DB_NAME(mid.database_id) AS DatabaseID ,
        CONVERT (DECIMAL(28, 1), migs.avg_total_user_cost
        * migs.avg_user_impact * ( migs.user_seeks + migs.user_scans )) AS improvement_measure ,
        'CREATE INDEX missing_index_'
        + CONVERT (VARCHAR, mig.index_group_handle) + '_'
        + CONVERT (VARCHAR, mid.index_handle) + ' ON ' + mid.statement + ' ('
        + ISNULL(mid.equality_columns, '')
        + CASE WHEN mid.equality_columns IS NOT NULL
                    AND mid.inequality_columns IS NOT NULL THEN ','
               ELSE ''
          END + ISNULL(mid.inequality_columns, '') + ')' + ISNULL(' INCLUDE ('
                                                              + mid.included_columns
                                                              + ')', '') AS create_index_statement ,
        migs.user_seeks ,
        migs.user_scans ,
        mig.index_group_handle ,
        mid.index_handle ,
        migs.* ,
        mid.database_id ,
        mid.[object_id]
FROM    sys.dm_db_missing_index_groups mig
        INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
        INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE   CONVERT (DECIMAL(28, 1), migs.avg_total_user_cost
        * migs.avg_user_impact * ( migs.user_seeks + migs.user_scans )) > 10 and DB_NAME(mid.database_id) like '%TSIGO%'
ORDER BY migs.avg_total_user_cost * migs.avg_user_impact * ( migs.user_seeks
                                                             + migs.user_scans ) DESC;
															 
------------------------------- INDICES SUGERIDOS OPTIMIZADOS

DECLARE @threshold_table_rows INT = 1000 , --> solo me interesan aquellas con algunas filas
    @threshold_table_updates INT = 10000;  --> a partir de estos cambios, se entiende que la tabla sufre muchas actualizaciones 

WITH    subquery
          AS ( SELECT   DB_NAME(mid.database_id) AS DatabaseID ,
                        CONVERT (DECIMAL(28, 1), migs.avg_total_user_cost
                        * migs.avg_user_impact * ( migs.user_seeks
                                                   + migs.user_scans )) AS improvement_measure ,
                        'CREATE INDEX missing_index_'
                        + CONVERT (VARCHAR, mig.index_group_handle) + '_'
                        + CONVERT (VARCHAR, mid.index_handle) + ' ON '
                        + mid.statement + ' (' + ISNULL(mid.equality_columns,
                                                        '')
                        + CASE WHEN mid.equality_columns IS NOT NULL
                                    AND mid.inequality_columns IS NOT NULL
                               THEN ','
                               ELSE ''
                          END + ISNULL(mid.inequality_columns, '') + ')'
                        + ISNULL(' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement ,
                        migs.user_seeks ,
                        migs.user_scans ,                      
                        ISNULL(CONVERT (INT, (-- Multiple partitions could correspond to one index.
                                               SELECT   SUM(rows)
                                               FROM     sys.partitions s_p
                                               WHERE    mid.object_id = s_p.object_id
                                                        AND s_p.index_id = 1 -- cluster index 
                                             )), 0) AS estimated_table_rows ,
                        sus.user_updates + sus.system_updates AS rows_updated
               FROM     sys.dm_db_missing_index_groups mig
                        INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
                        INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
                        LEFT JOIN sys.dm_db_index_usage_stats sus ON sus.index_id = 1 --> quiero solo el indice clustered
                                                              AND sus.object_id = mid.object_id
                                                              AND sus.database_id = mid.database_id
               WHERE    mid.database_id = DB_ID()
                        AND CONVERT (DECIMAL(28, 1), migs.avg_total_user_cost
                        * migs.avg_user_impact * ( migs.user_seeks
                                                   + migs.user_scans )) > 10
             )
    SELECT  *
    FROM    subquery
	WHERE subquery.rows_updated < @threshold_table_updates
	AND subquery.estimated_table_rows > @threshold_table_rows
    ORDER BY improvement_measure DESC;