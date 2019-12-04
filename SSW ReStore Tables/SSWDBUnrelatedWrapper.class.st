"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBUnrelatedWrapper,
	#superclass : #SSWDBWrapper,
	#category : #'SSW ReStore Tables'
}

{ #category : #defining }
SSWDBUnrelatedWrapper >> defineAs: aSymbol in: aDBTable [

	"Define the wrapped object, making the resulting object unrelated"
		
	^(self unrelatedObject defineAs: aSymbol in: aDBTable) 
		beUnrelated;
		yourself
]

{ #category : #accessing }
SSWDBUnrelatedWrapper >> unrelatedObject [

	^self object
]
