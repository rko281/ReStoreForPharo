"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStoreFullTableTest',
	#superclass : 'SSWReStoreTableTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'helpers' }
SSWReStoreFullTableTest >> createTestData [

	reStore destroyAllClasses.

	reStore enableFullTableRecords.
	reStore sqlDialect maxTableNameLength: 9.
	
	^super createTestData 
]

{ #category : 'constants' }
SSWReStoreFullTableTest >> renamedTableName [

	"SIMPLE_PERSON and SIMPLE_ADDRESS use us SIMPL_0 and SIMPL_1"

	^'SIMPL_2'
]
