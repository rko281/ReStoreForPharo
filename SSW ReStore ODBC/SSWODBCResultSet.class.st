Class {
	#name : 'SSWODBCResultSet',
	#superclass : 'ODBCResultSet',
	#category : 'SSW ReStore ODBC',
	#package : 'SSW ReStore ODBC'
}

{ #category : 'constants' }
SSWODBCResultSet >> bufferClass [
	"Private - Answer the buffer class to use for DBResultSets (e.g. DBBoundRow for bound buffers 
	where memory is allocated and bound using SQLBindCol, or DBUnboundRow for unbound buffers 
	which are retrieved individually)."

	^SSWODBCBoundBuffer
]

{ #category : 'accessing' }
SSWODBCResultSet >> cursorType [

	^statement cursorType
]

{ #category : 'accessing' }
SSWODBCResultSet >> position: anInteger [

	self moveTo: anInteger
]

{ #category : 'accessing' }
SSWODBCResultSet >> readStream [

	^SSWDBReadStream on: self
]

{ #category : 'accessing' }
SSWODBCResultSet >> resetAndFetchFirst [

	^self first
]

{ #category : 'accessing' }
SSWODBCResultSet >> size [

	"Return nil if not known"

	| numRows |

	numRows := self numRows.

	"Normally -1 (or sometimes less) indicates unknown. However SQLite (at least) returns zero, so err on the side of caution"
	^numRows <= 0
		ifTrue: [nil]
		ifFalse: [numRows]
]
