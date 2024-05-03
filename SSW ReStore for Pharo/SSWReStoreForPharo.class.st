Class {
	#name : 'SSWReStoreForPharo',
	#superclass : 'Object',
	#category : 'SSW ReStore for Pharo',
	#package : 'SSW ReStore for Pharo'
}

{ #category : 'class initialization' }
SSWReStoreForPharo class >> initialize [

	Smalltalk at: #ReStore put: SSWReStore globalDefault
]
