Class {
	#name : 'SSWMySQLCommandExecute',
	#superclass : 'MySQLCommandExecute',
	#category : 'SSW ReStore MySQL',
	#package : 'SSW ReStore MySQL'
}

{ #category : 'reading' }
SSWMySQLCommandExecute >> resultSetClass [

	^SSWMySQLResultSet
]

{ #category : 'accessing' }
SSWMySQLCommandExecute >> rowClass [
				   
	^SSWMySQLRow
]
