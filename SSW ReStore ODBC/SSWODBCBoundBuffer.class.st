Class {
	#name : 'SSWODBCBoundBuffer',
	#superclass : 'ODBCBoundBuffer',
	#category : 'SSW ReStore ODBC',
	#package : 'SSW ReStore ODBC'
}

{ #category : 'converting' }
SSWODBCBoundBuffer >> asObject [
	"Private - Answer the receiver as an instance of DBRow containing the receiver's values."

	^SSWODBCRow fromBuffer: self
]

{ #category : 'accessing' }
SSWODBCBoundBuffer >> contents [
	"Answer the contents instance variable."

	contents isNil
		ifTrue: [contents := columns collect: [:colAttr | SSWODBCField newForCol: colAttr]].
	^contents
]
