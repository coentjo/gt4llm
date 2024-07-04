Class {
	#name : #GtOpenAIWardleyMapActionThreadMessage,
	#superclass : #GtOpenAIThreadMessage,
	#category : #'Gt4OpenAI-Examples - Wardley Map'
}

{ #category : #accessing }
GtOpenAIWardleyMapActionThreadMessage >> action [
	| parsed |
	self isAssistantRole ifFalse: [ ^ '' ].

	parsed := LeParser parse: self contentText.

	parsed children
		do: [ :aNode | 
			((aNode isKindOf: LeCodeBlockNode) and: [ aNode isForLanguage: 'action' ])
				ifTrue: [ ^ aNode code source ] ].
	^ ''
]

{ #category : #accessing }
GtOpenAIWardleyMapActionThreadMessage >> actionHeaderItem [
	<gtLlmHeaderItem: 4>
	^ BrLabel new
			hFitContentLimited;
			vFitContent;
			aptitude: (BrGlamorousLabelAptitude new
					foreground: BrGlamorousColors disabledButtonTextColor);
			beSmallSize;
			text: self action
]

{ #category : #accessing }
GtOpenAIWardleyMapActionThreadMessage >> ancestor [
	^ self chat ancestorOf: self
]

{ #category : #accessing }
GtOpenAIWardleyMapActionThreadMessage >> asViewModel [
	^ GtLlmActionThreadMessageViewModel new threadMessage: self
]

{ #category : #accessing }
GtOpenAIWardleyMapActionThreadMessage >> diffedMapModel [
	| ownModel differ |
	ownModel := self mapModel.

	self ancestor ifNil: [ ^ ownModel ].
	self ancestor mapModel ifNil: [ ^ ownModel ].

	differ := GtWardleyMapDiffer diffFrom: self ancestor mapModel to: ownModel.

	differ addedEdges
		do: [ :anEdge | anEdge addWardleyMapDecoratorModel: GtWardleyMapAddProposition new ].
	differ addedNodes
		do: [ :aNode | aNode addWardleyMapDecoratorModel: GtWardleyMapAddProposition new ].
	differ removedNodes
		do: [ :aNode | 
			ownModel
				addNode: (aNode removeParent
						addWardleyMapDecoratorModel: GtWardleyMapRemoveProposition new) ].
	differ removedEdges
		do: [ :anEdge | 
			| newEdge |
			newEdge := GtWardleyMapEdgeModel new
					fromNode: (ownModel
							nodeWithName: anEdge fromNode label
							ifFound: #yourself
							ifNone: [ self error: 'Node not found' ]);
					toNode: (ownModel
							nodeWithName: anEdge toNode label
							ifFound: #yourself
							ifNone: [ self error: 'Node not found' ]);
					addWardleyMapDecoratorModel: GtWardleyMapRemoveProposition new.
			ownModel addEdge: newEdge ].

	^ ownModel
]

{ #category : #accessing }
GtOpenAIWardleyMapActionThreadMessage >> explanationCodeBlock [
	^ self codeBlocks
		detect: [ :aCodeBlock | aCodeBlock isForLanguage: 'explanation' ]
		ifNone: [ nil ]
]

{ #category : #accessing }
GtOpenAIWardleyMapActionThreadMessage >> gtActionFor: aView [
	<gtView>
	<gtLlmMessageView>
	self action ifEmpty: [ ^ aView empty ].

	^ aView textEditor
		title: 'Action';
		priority: 3;
		text: [ self action ]
]

{ #category : #accessing }
GtOpenAIWardleyMapActionThreadMessage >> gtContentFor: aView [
	<gtView>
	<gtLlmMessageView>
	^ aView explicit
		title: 'Content';
		priority: 5;
		stencil: [ GtLlmActionThreadMessageElement new threadMessageViewModel: self asViewModel ]
]

{ #category : #accessing }
GtOpenAIWardleyMapActionThreadMessage >> gtExplanationFor: aView [
	<gtView>
	<gtLlmMessageView>
	self explanationCodeBlock ifNil: [ ^ aView empty ].

	^ aView textEditor
		title: 'Explanation';
		priority: 2;
		text: [ self explanationCodeBlock code value ];
		styler: (GtLlmMessageStyler new threadMessageViewModel: self)
]

{ #category : #accessing }
GtOpenAIWardleyMapActionThreadMessage >> gtWardleyMapFor: aView [
	<gtView>
	<gtLlmMessageView>
	self mapCodeBlock ifNil: [ ^ aView empty ].

	^ aView explicit
		title: 'Map';
		priority: 1;
		stencil: [ GtWardleyMapElement new
				wardleyMapViewModel: (GtWardleyMapViewModel new
						wardleyMapModel: self diffedMapModel;
						openAITutorChat: self chat);
				vExact: 500 ]
]

{ #category : #accessing }
GtOpenAIWardleyMapActionThreadMessage >> mapCodeBlock [
	^ self codeBlocks
		detect: [ :aCodeBlock | aCodeBlock isForLanguage: 'wardley-map' ]
		ifNone: [ nil ]
]

{ #category : #accessing }
GtOpenAIWardleyMapActionThreadMessage >> mapModel [
	self mapCodeBlock ifNil: [ ^ nil ].
	^ (GtWardleyMapParser parse: self mapCodeBlock code value) asWardleyMapModel
]

{ #category : #accessing }
GtOpenAIWardleyMapActionThreadMessage >> spacerHeaderItem [
	<gtLlmHeaderItem: 3>
	^ BrFrame new matchParent
]