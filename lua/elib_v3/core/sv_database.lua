// Script made by Eve Haddox
// discord evehaddox
// database module by imLiaMxo

///////////////////
// Database Module
///////////////////

Elib.Database = Elib.Database or {}
Elib.Database.Registered = Elib.Database.Registered or {}


local DATABASE = {}
DATABASE.__index = DATABASE

// Check if MySQLoo is available
local MYSQLOO_AVAILABLE = false
if mysqloo then
    MYSQLOO_AVAILABLE = true
    MsgC(Color(49, 149, 207), "[Elib Database] ", Color(230, 230, 230), "MySQLoo detected and available\n")
else
    MsgC(Color(207, 144, 49), "[Elib Database] ", Color(230, 230, 230), "MySQLoo not found, only SQLite available\n")
end

///////////////////
// Create Database Instance
///////////////////
function Elib.NewDatabase(addonName)
    local db = setmetatable({}, DATABASE)
    
    db.addonName = addonName or "Unknown"
    db.useMySQL = false
    db.connected = false
    db.mysqlConnection = nil
    db.queryQueue = {}
    db.processing = false
    db.debug = false
    
    // Register this database
    table.insert(Elib.Database.Registered, db)
    
    MsgC(Color(49, 149, 207), "[Elib Database] ", Color(230, 230, 230), "Initialized database for: " .. db.addonName .. "\n")
    
    return db
end

///////////////////
// Configuration
///////////////////
function DATABASE:UseMySQL(enabled)
    if enabled and not MYSQLOO_AVAILABLE then
        ErrorNoHalt("[Elib Database] Cannot enable MySQL - MySQLoo is not installed!\n")
        return false
    end
    
    self.useMySQL = enabled
    
    if enabled then
        MsgC(Color(49, 149, 207), "[Elib.Database:" .. self.addonName .. "] ", Color(230, 230, 230), "Switched to MySQL mode\n")
    else
        MsgC(Color(49, 149, 207), "[Elib.Database:" .. self.addonName .. "] ", Color(230, 230, 230), "Switched to SQLite mode\n")
    end
    
    return true
end

function DATABASE:SetDebug(enabled)
    self.debug = enabled
end

function DATABASE:Connect(host, username, password, database, port)
    if not self.useMySQL then
        self.connected = true
        MsgC(Color(49, 149, 207), "[Elib.Database:" .. self.addonName .. "] ", Color(35, 172, 35), "Using SQLite (no connection needed)\n")
        return true
    end
    
    if not MYSQLOO_AVAILABLE then
        ErrorNoHalt("[Elib.Database:" .. self.addonName .. "] Cannot connect - MySQLoo is not installed!\n")
        return false
    end
    
    port = port or 3306
    
    self.mysqlConnection = mysqloo.connect(host, username, password, database, port)
    
    self.mysqlConnection.onConnected = function()
        self.connected = true
        MsgC(Color(49, 149, 207), "[Elib.Database:" .. self.addonName .. "] ", Color(35, 172, 35), "Successfully connected to MySQL database\n")
        self:ProcessQueue()
    end
    
    self.mysqlConnection.onConnectionFailed = function(db, err)
        self.connected = false
        ErrorNoHalt("[Elib.Database:" .. self.addonName .. "] Connection failed: " .. err .. "\n")
    end
    
    self.mysqlConnection:connect()
    
    return true
end

function DATABASE:IsConnected()
    return self.connected
end

///////////////////
// String Escaping
///////////////////
function DATABASE:Escape(str)
    if not str then return "" end
    
    if self.useMySQL and self.mysqlConnection then
        return self.mysqlConnection:escape(tostring(str))
    else
        return sql.SQLStr(tostring(str), true)
    end
end

///////////////////
// Query Formatting
///////////////////
function DATABASE:Format(query, ...)
    local args = {...}
    local escaped = {}
    
    for i, arg in ipairs(args) do
        if type(arg) == "string" then
            escaped[i] = self:Escape(arg)
        elseif type(arg) == "number" then
            escaped[i] = tostring(arg)
        elseif type(arg) == "boolean" then
            escaped[i] = arg and "1" or "0"
        elseif arg == nil then
            escaped[i] = "NULL"
        else
            escaped[i] = self:Escape(tostring(arg))
        end
    end
    
    return string.format(query, unpack(escaped))
end

///////////////////
// Query Execution
///////////////////
function DATABASE:Query(query, callback, errorCallback)
    if self.debug then
        MsgC(Color(49, 149, 207), "[Elib.Database:" .. self.addonName .. "] ", Color(230, 230, 230), "Query: " .. query .. "\n")
    end
    
    if self.useMySQL then
        return self:QueryMySQL(query, callback, errorCallback)
    else
        return self:QuerySQLite(query, callback, errorCallback)
    end
end

function DATABASE:QuerySQLite(query, callback, errorCallback)
    local result = sql.Query(query)
    
    if result == false then
        local error = sql.LastError()
        ErrorNoHalt("[Elib.Database:" .. self.addonName .. "] SQLite Error: " .. error .. "\n")
        ErrorNoHalt("Query was: " .. query .. "\n")
        
        if errorCallback then
            errorCallback(error)
        end
        
        return false, error
    end
    
    if callback then
        callback(result or {})
    end
    
    return true, result
end

function DATABASE:QueryMySQL(query, callback, errorCallback)
    if not self.connected then
        // Queue the query for when we connect
        table.insert(self.queryQueue, {
            query = query,
            callback = callback,
            errorCallback = errorCallback
        })
        return
    end
    
    local q = self.mysqlConnection:query(query)
    
    q.onSuccess = function(q, data)
        if callback then
            callback(data or {})
        end
    end
    
    q.onError = function(q, err)
        ErrorNoHalt("[Elib.Database:" .. self.addonName .. "] MySQL Error: " .. err .. "\n")
        ErrorNoHalt("Query was: " .. query .. "\n")
        
        if errorCallback then
            errorCallback(err)
        end
    end
    
    q:start()
    
    return q
end

function DATABASE:ProcessQueue()
    if self.processing or not self.connected then return end
    if #self.queryQueue == 0 then return end
    
    self.processing = true
    
    local queue = table.Copy(self.queryQueue)
    self.queryQueue = {}
    
    for _, data in ipairs(queue) do
        self:QueryMySQL(data.query, data.callback, data.errorCallback)
    end
    
    self.processing = false
end

///////////////////
// Prepared Statements (MySQL only)
///////////////////
function DATABASE:Prepare(query)
    if not self.useMySQL then
        ErrorNoHalt("[Elib.Database:" .. self.addonName .. "] Prepared statements are only available with MySQL\n")
        return nil
    end
    
    if not self.connected or not self.mysqlConnection then
        ErrorNoHalt("[Elib.Database:" .. self.addonName .. "] Not connected to MySQL\n")
        return nil
    end
    
    return self.mysqlConnection:prepare(query)
end

///////////////////
// Transaction Support
///////////////////
function DATABASE:BeginTransaction(callback, errorCallback)
    self:Query("START TRANSACTION", callback, errorCallback)
end

function DATABASE:Commit(callback, errorCallback)
    self:Query("COMMIT", callback, errorCallback)
end

function DATABASE:Rollback(callback, errorCallback)
    self:Query("ROLLBACK", callback, errorCallback)
end

function DATABASE:Transaction(queries, callback, errorCallback)
    self:BeginTransaction(function()
        local completed = 0
        local failed = false
        
        local function checkComplete()
            completed = completed + 1
            
            if failed then return end
            
            if completed >= #queries then
                self:Commit(function()
                    if callback then callback() end
                end, errorCallback)
            end
        end
        
        local function onError(err)
            if failed then return end
            failed = true
            
            self:Rollback(function()
                if errorCallback then errorCallback(err) end
            end)
        end
        
        for _, query in ipairs(queries) do
            self:Query(query, checkComplete, onError)
        end
    end, errorCallback)
end

///////////////////
// Helper Functions
///////////////////
function DATABASE:TableExists(tableName, callback)
    if self.useMySQL then
        local query = string.format("SHOW TABLES LIKE '%s'", self:Escape(tableName))
        self:Query(query, function(data)
            callback(data and #data > 0)
        end)
    else
        local query = string.format("SELECT name FROM sqlite_master WHERE type='table' AND name='%s'", self:Escape(tableName))
        self:Query(query, function(data)
            callback(data and #data > 0)
        end)
    end
end

function DATABASE:CreateTable(tableName, columns, callback, errorCallback)
    local columnDefs = {}
    
    for name, def in pairs(columns) do
        table.insert(columnDefs, name .. " " .. def)
    end
    
    local query = string.format("CREATE TABLE IF NOT EXISTS %s (%s)", tableName, table.concat(columnDefs, ", "))
    
    self:Query(query, callback, errorCallback)
end

function DATABASE:DropTable(tableName, callback, errorCallback)
    local query = string.format("DROP TABLE IF EXISTS %s", tableName)
    self:Query(query, callback, errorCallback)
end

function DATABASE:Insert(tableName, data, callback, errorCallback)
    local columns = {}
    local values = {}
    
    for col, val in pairs(data) do
        table.insert(columns, col)
        
        if type(val) == "string" then
            table.insert(values, "'" .. self:Escape(val) .. "'")
        elseif type(val) == "number" then
            table.insert(values, tostring(val))
        elseif type(val) == "boolean" then
            table.insert(values, val and "1" or "0")
        elseif val == nil then
            table.insert(values, "NULL")
        else
            table.insert(values, "'" .. self:Escape(tostring(val)) .. "'")
        end
    end
    
    local query = string.format("INSERT INTO %s (%s) VALUES (%s)", 
        tableName, 
        table.concat(columns, ", "), 
        table.concat(values, ", ")
    )
    
    self:Query(query, callback, errorCallback)
end

function DATABASE:Update(tableName, data, where, callback, errorCallback)
    local sets = {}
    
    for col, val in pairs(data) do
        local valueStr
        
        if type(val) == "string" then
            valueStr = "'" .. self:Escape(val) .. "'"
        elseif type(val) == "number" then
            valueStr = tostring(val)
        elseif type(val) == "boolean" then
            valueStr = val and "1" or "0"
        elseif val == nil then
            valueStr = "NULL"
        else
            valueStr = "'" .. self:Escape(tostring(val)) .. "'"
        end
        
        table.insert(sets, col .. " = " .. valueStr)
    end
    
    local query = string.format("UPDATE %s SET %s WHERE %s", 
        tableName, 
        table.concat(sets, ", "), 
        where
    )
    
    self:Query(query, callback, errorCallback)
end

function DATABASE:Delete(tableName, where, callback, errorCallback)
    local query = string.format("DELETE FROM %s WHERE %s", tableName, where)
    self:Query(query, callback, errorCallback)
end

function DATABASE:Select(tableName, columns, where, callback, errorCallback)
    local columnStr = type(columns) == "table" and table.concat(columns, ", ") or columns or "*"
    local whereStr = where and (" WHERE " .. where) or ""
    
    local query = string.format("SELECT %s FROM %s%s", columnStr, tableName, whereStr)
    
    self:Query(query, callback, errorCallback)
end

function DATABASE:Count(tableName, where, callback, errorCallback)
    local whereStr = where and (" WHERE " .. where) or ""
    local query = string.format("SELECT COUNT(*) as count FROM %s%s", tableName, whereStr)
    
    self:Query(query, function(data)
        if callback and data and data[1] then
            callback(tonumber(data[1].count) or 0)
        end
    end, errorCallback)
end

///////////////////
// Cleanup
///////////////////
function DATABASE:Disconnect()
    if self.useMySQL and self.mysqlConnection then
        self.mysqlConnection:disconnect()
        self.connected = false
        MsgC(Color(49, 149, 207), "[Elib.Database:" .. self.addonName .. "] ", Color(230, 230, 230), "Disconnected from MySQL\n")
    end
end

///////////////////
// Global Cleanup
///////////////////
hook.Add("ShutDown", "Elib.Database.Cleanup", function()
    for _, db in ipairs(Elib.Database.Registered) do
        db:Disconnect()
    end
end)