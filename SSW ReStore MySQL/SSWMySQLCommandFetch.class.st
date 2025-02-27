Class {
	#name : 'SSWMySQLCommandFetch',
	#superclass : 'MySQLCommandFetch',
	#instVars : [
		'connectionSpec'
	],
	#category : 'SSW ReStore MySQL',
	#package : 'SSW ReStore MySQL'
}

{ #category : 'accessing' }
SSWMySQLCommandFetch >> rowClass [
	^SSWMySQLRow
]
