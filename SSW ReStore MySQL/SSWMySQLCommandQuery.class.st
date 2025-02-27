Class {
	#name : 'SSWMySQLCommandQuery',
	#superclass : 'MySQLCommandQuery',
	#instVars : [
		'connectionSpec'
	],
	#category : 'SSW ReStore MySQL',
	#package : 'SSW ReStore MySQL'
}

{ #category : 'reading' }
SSWMySQLCommandQuery >> resultSetClass [

	^SSWMySQLResultSet
]
