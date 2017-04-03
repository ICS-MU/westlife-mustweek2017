define(_NODE_SERVER_,     ifdef(`_CFM_',`example.nodes.MonitoredServer',`example.nodes.Server'))dnl
define(_NODE_WEBSERVER_,  ifdef(`_CFM_',`example.nodes.MonitoredWebServer', `example.nodes.WebServer'))dnl
define(_NODE_DBMS_,       ifdef(`_CFM_',`example.nodes.MonitoredDBMS', `example.nodes.DBMS'))dnl
