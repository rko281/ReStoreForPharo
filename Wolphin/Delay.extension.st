Extension { #name : #Delay }

{ #category : #'*Wolphin' }
Delay class >> forMicroseconds: anInteger [

	^self forMilliseconds: ((anInteger // 1000) max: 1)

]
