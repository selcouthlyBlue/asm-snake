COMMENT @
Jerome Patrick V. Gonzalvo
2012-14784
Snake 131
@

.model small
.data
    mode db	                03h
    startPosX db            39
    startPosY db            12
    bodyChar db             14
    wdir db                 119, 48h, 87
    sdir db                 115, 50h, 83
    adir db                 97, 4bh, 65
    ddir db                 100, 4dh, 68
    snakeColor db           13h
    cycle dw                0
    index dw                0
	specialFoodTime EQU 	50
	boolSpecialFood db 		0
    maxX dw                 78
    maxY dw                 22
    food db                 01h
	foodToSpawn db 			?
	foodColor db			?
	specialFood db 			03h, 04h, 05h, 06h, 12h
	specialFoodEffect db	12h, 23h, 34h, 45h, 56h
	specialFoodColor db		02h, 03h, 04h, 05h, 06h
	colorSwitcher db		?
	normalFoodEaten db		0
	prevkey	   db			?
    input db                ?
    xpos db                 ?
    ypos db                 ?
    foodPosX db             ?
    foodPosY db             ?
	headPosX dw				0
	headPosY dw				0
	tailPosX dw       		0
	tailPosY dw				0
    snakeLength dw			5
	partCount   dw			1
	boolCopied db			0
	upChar EQU				30
	downChar EQU			31
	leftChar EQU			17
	rightChar EQU			16
	promptGameOver db "Game over$"
	promptScore db "Your score:   $"
	promptRetry db 'Want to play again?', '$'
	choices db 'Yes       No', '$'
	promptTY db 'Thank you for playing! n___n', '$'
	arrow db 16
	mychoice db 'y'
	score dw 0
	digit db ?
	digitPosX db ?
	digitPosY db ?
	curCX dw ?
	maxBoundX EQU 79
	maxBoundY EQU 24
	minBoundX EQU 0
	minBoundY EQU 1
	
	snakeArt1 db "  _________              __           $"
	snakeArt2 db " /   _____/ ____ _____  |  | __ ____  $"
	snakeArt3 db " \_____  \ /    \\__  \ |  |/ // __ \ $"
	snakeArt4 db " /        \   |  \/ __ \|    <\  ___/ $"
	snakeArt5 db "/_______  /___|  (____  /__|_ \\___  >$"
	snakeArt6 db "        \/     \/     \/     \/    \/ $"
	
	pausePrompt db "Game paused$"
	blankSpaces db "           $"
	pauseButton db ' '
	
	startPrompt db "   Press any key to start the game    $"
	lastKeyPressed db ?
.stack 100h
.code

    setCursorPos macro x, y
        mov dh, y
        mov dl, x
        xor bh, bh
        mov ah, 02h
        int 10h
    endm
	
	setDigitPos macro x, y
		mov digitPosX, x
		mov digitPosY, y
	endm

	printChar macro char, color
        mov al, char
        xor bh, bh
        mov bl, color
        xor cx, cx
        mov cx, 1
        mov ah, 09h
        int 10h
    endm
	
	printString macro charString
		lea dx, charString
		mov ah, 09h
		int 21h
	endm
	
	loadPrompts proc
		call clearScreen
		call clearRegisters
		setCursorPos 30, 10
		printString promptGameOver
		setCursorPos 30, 11
		printString promptScore
		setDigitPos 45, 11
		call displayScore
		setCursorPos 30, 12
		printString promptRetry
		setCursorPos 34, 13
		printString choices
		ret
	loadPrompts endp
	
	loadTYPrompt proc
		call clearscreen
		call clearRegisters
		mov xpos, 26
		
		setCursorPos xpos, 12
		lea dx, promptTY
        mov ah, 09h
        int 21h
		
		mov ah, 00h
		int 16h
		
		call clearScreen
		
		mov ax, 4c00h
        int 21h
		ret
	loadTYPrompt endp
	
	copy macro dest, source
        mov cl, source
        mov dest, cl
    endm
	
	copy2 macro dest, source
		mov cx, source
		mov dest, cx
	endm
	
	printString2 macro charString, x, y
		mov dh, y
        mov dl, x
        xor bh, bh
        mov ah, 02h
        int 10h 
        mov dx, offset charString
        mov ah, 09h
        int 21h
	endm
	
	mainMenu proc
		printString2 snakeArt1, 20, 5
		printString2 snakeArt2, 20, 6
		printString2 snakeArt3, 20, 7
		printString2 snakeArt4, 20, 8
		printString2 snakeArt5, 20, 9
		printString2 snakeArt6, 20, 10
		printString2 startPrompt, 20, 15
		ret
	mainMenu endp
	
	gameover proc
		call clearScreen
		call loadPrompts
		setCursorPos 32, 13 
		printChar arrow, 0fh 
		
		choose:
		mov index, 0
        mov ah, 00h
        int 16h
		
		cmp al, 00h
		jne wsadInput2
		
		mov input, ah
		jmp cmpDir2
		
		wsadInput2:
        mov input, al
		
		cmpDir2:
        mov bx, index
		mov al, input
		cmp al, [adir+bx]
		je chooseYes
		cmp al, [ddir+bx]
		je chooseNo
		inc index
		cmp index, 3
		jl cmpDir2
		
		jmp done
		
		chooseYes:
		printChar ' ', 00h
        mov mychoice, 'y'
		setCursorPos 32, 13
		jmp done
		
		chooseNo:
		printChar ' ', 00h
		mov mychoice, 'n'
		setCursorPos 42, 13
		
		done:
		printChar arrow, 0fh
		cmp input, 13
		jne choose
		
		cmp mychoice, 'y'
		je playagain
		
		call loadTYPrompt
		
		playagain:
		call clearRegisters
		call clearScreen
		mov snakeLength, 5
		mov partCount, 1
		mov boolCopied, 0
		mov input, 'd'
		mov prevkey, 'd'
		mov lastKeyPressed, 'd'
		mov score, 0
		mov cycle, 0
		mov boolSpecialFood, 0
		mov normalFoodEaten, 0
		mov snakeColor, 12h
        ret
    gameover endp
	
	displayScore proc				;Procedure TO DISPLAY
		mov ax, score
		mov bx, 10			;initializes divisor
		mov dx, 0000h			;clears dx
		mov cx, 0000h			;clears cx
	dloop1:	
		mov dx, 0000h			;clears dx during jump
		div bx				;divides ax by bx
		push dx				;pushes dx(remainder) to stack
		inc cx				;increments counter to track the number of digits
		cmp ax, 0			;checks if there is still something in ax to divide
		jne dloop1			;jumps if ax is not zero				
	dloop2:	
		pop dx				;pops from stack to dx
		add dx, 30h			;converts to it's ascii equivalent
		mov curCX, cx
		mov digit, dl
		setCursorPos digitPosX, digitPosY 
		printChar digit, 02h 
		inc digitPosX
		mov cx, curCX
		loop dloop2			;loops till cx equals zero
		ret				;returns control		
	displayScore endp

    random macro maxCoor
        mov ah, 00h     
        int 1ah         
    
        mov  ax, dx
        xor  dx, dx
        mov  cx, maxCoor     
        div  cx         
    endm
	
	scanChar proc
		mov ah, 08h
		int 10h
		ret
	scanChar endp

    keystroke proc
        mov ah, 01h
        int 16h
        jz nopress

        mov ah, 00h
        int 16h
		
		cmp al, 00h
		jne wsadInput
		
		mov input, ah
		jmp nopress
		
		wsadInput:
        mov input, al
		
        nopress:
        ret
    keystroke endp
	
	spawnfood proc
		cmp normalFoodEaten, 5
		jne spawnNormalFood
		
		epicMealTime:
		random 5
		mov bx, dx
		copy foodToSpawn, [specialFood+bx]
		copy colorSwitcher, [specialFoodEffect+bx]
		copy foodColor, [specialFoodColor+bx]
		mov boolSpecialFood, 1
		jmp checkCycle
		
		spawnNormalFood:
		copy foodToSpawn, food
		mov foodColor, 0fh
		
		checkCycle:
        cmp cycle, 0
        jne setFood
		
		setFoodPos:
        random maxX
        mov foodPosX, dl
		inc foodPosX
        random maxY
        mov foodPosY, dl
		inc foodPosY
		inc foodPosY

        setFood:
        setCursorPos foodPosX, foodPosY 
		call scanChar
		
		cmp ah, snakeColor
		jne spawn
		
		jmp setFoodPos
		
		spawn:
        printChar foodToSpawn, foodColor
        ret
    spawnfood endp

    waitAmillisec proc
        mov ah, 00
		int 1Ah
		mov bx, dx

	jmp_delay:
		int 1Ah
		sub dx, bx
		cmp dl, 1
		jl jmp_delay
        inc cycle
		cmp boolSpecialFood, 0
		je proceed
		
		cmp cycle, specialFoodTime
		jle proceed
		
		mov boolSpecialFood, 0
		mov normalFoodEaten, 0

		newFoodPos:
        mov cycle, 0
		setCursorPos foodPosX, foodPosY
		printChar ' ', 00h

        proceed:
        ret
    waitAmillisec endp

    clearRegisters proc
        xor ax, ax
        xor bx, bx
        xor cx, cx
        xor dx, dx
        ret
    clearRegisters endp
	
	moveDir macro key, snakePart, pos, bound
		mov prevkey, key
		mov bodyChar, snakePart
		cmp pos, bound
	endm
	
	upMove proc
		moveDir 'w', upChar, ypos, minBoundY
        jne up
    
        mov ypos, maxBoundY
		copy2 headPosY, snakeLength
        ret
    
        up:
        dec ypos
		ret
	upMove endp
	
	downMove proc
		moveDir 's', downChar, ypos, maxBoundY
        jne down
    
        mov ypos, minBoundY
		copy2 headPosY, snakeLength
        ret
    
        down:
        inc ypos
		ret
	downMove endp
	
	leftMove proc
		moveDir 'a', leftChar, xpos, minBoundX
        jne left
    
        mov xpos, maxBoundX
		copy2 headPosX, snakeLength
        ret
    
        left:
        dec xpos
		ret
	leftMove endp
	
	rightMove proc
		moveDir 'd', rightChar, xpos, maxBoundX
        jne right
    
        mov xpos, minBoundX
		copy2 headPosX, snakeLength
        ret
    
		right:
        inc xpos
		ret
	rightMove endp

    clearScreen proc
        mov ax, 0600h
        mov bh, 07h
        xor cx, cx
        mov dx, 184fh
        int 10h
        ret
    clearScreen endp

    initgraphics proc
        mov al,mode			
        mov ah,00			      
        int 10h			     
        ret
    initgraphics endp

    closegraphics proc
        mov ax, 0003h      
        int 10h
        ret
    closegraphics endp

    main    proc

    mov ax, @data
    mov ds, ax

    call initgraphics

    mov cx, 3200h
    mov ah, 01h
    int 10h

    call mainMenu

    mov ah, 00h
    int 16h
    
    mov input, 'd'
	mov prevkey, 'd'
    call clearScreen

	gameStart:
	setCursorPos startPosX, startPosY 
	mov xpos, dl
	mov ypos, dh

    readchar:
	call spawnfood
    call keystroke

    mov index, 0
	call clearRegisters
    
    cmpDir:
    mov bx, index
    mov al, input
	cmp al, pauseButton
	je pauseGame
	cmp al, [ddir+bx]
    je moveright
    cmp al, [wdir+bx]
    je moveup
    cmp al, [sdir+bx]
    je movedown
    cmp al, [adir+bx]
    je moveleft
    inc index
    cmp index, 3
    jl cmpDir
	
	jmp checkInputAgain
	
	pauseGame:
	printString2 pausePrompt, 3, 0 
	mov ah, 00h
	int 16h
	cmp al, pauseButton
	jne pauseGame
	
	printString2 blankSpaces, 3, 0
    
	checkInputAgain:
	mov index, 0
	copy input, lastKeyPressed
    jmp cmpDir
	
    moveup:
		cmp lastKeyPressed, 's'
		je movedown
		
		call upMove
        jmp keepmoving

    movedown:
		cmp lastKeyPressed, 'w'
		je moveup
		
		call downMove
        jmp keepmoving

    moveleft:
		cmp lastKeyPressed, 'd'
		je moveright
		
		call leftMove
        jmp keepmoving

    moveright:		
		cmp lastKeyPressed, 'a'
		je moveleft
		
		call rightMove
		
    keepmoving:
		setCursorPos xpos, ypos
		
		xor cx, cx
		mov cl, xpos
		cmp cx, headPosX
		jne checkTail
		
		xor cx, cx
		mov cl, ypos
		cmp cx, headPosY
		jne checkTail
		
		jmp dead
		
		checkTail:
		xor cx, cx
		mov cl, xpos
		cmp cx, tailPosX
		jne notDead
		
		xor cx, cx
		mov cl, ypos
		cmp cx, tailPosY
		jne notDead
		
		dead:
		call clearScreen
		call gameOver
		jmp gameStart
		
		notDead:
		mov cl, xpos
		cmp cl, foodPosX
		jne copyHeadPos
		
		mov cl, ypos
		cmp cl, foodPosY
		jne copyHeadPos
		
		cmp boolSpecialFood, 0
		je eatNormalFood
		
		add snakeLength, 5
		add score, 5
		copy snakeColor, colorSwitcher
		mov boolSpecialFood, 0
		mov normalFoodEaten, 0
		mov cycle, 0
		
		jmp copyHeadPos
		
		eatNormalFood:
		add snakeLength, 2
		add score, 2
		inc normalFoodEaten
		mov cycle, 0
		
		copyHeadPos:
		cmp boolCopied, 0
		jne keeplooking
		
		xor ax, ax
		mov al, xpos
		copy2 headPosX, ax
		mov al, ypos
		copy2 headPosY, ax
		copy lastKeyPressed, prevkey
		mov boolCopied, 1
		
		keepLooking:
		mov cx, partCount
        printbody:
			setCursorPos xpos, ypos
			printChar bodyChar, snakeColor
			cmp cx, snakeLength
			je move
			call scanChar
			cmp al, rightChar
			je checkForRightPart
			cmp al, upChar
			je checkForUpPart
			cmp al, downChar
			je checkForDownPart
			cmp al, leftChar
			je checkForLeftPart
			
			checkForUpPart:
				cmp ypos, maxBoundY
				jne goUp
				
				mov ypos, minBoundY
				jmp checkPrevChar
				
				goUp:
				inc ypos
			jmp checkPrevChar
			
			checkForDownPart:
				cmp ypos, minBoundY
				jne goDown
				
				mov ypos, maxBoundY
				jmp checkPrevChar
				
				goDown:
				dec ypos
			jmp checkPrevChar
			
			checkForLeftPart:
				cmp xpos, maxBoundX
				jne goLeft
				
				mov xpos, minBoundX
				jmp checkPrevChar
				
				goLeft:
				inc xpos
			jmp checkPrevChar
				
			checkForRightPart:
				cmp xpos, minBoundX
				jne goRight
				
				mov xpos, maxBoundX
				jmp checkPrevChar
				
				goRight:
				dec xpos
			
			checkPrevChar:
			setCursorPos xpos, ypos 
			call scanChar
			inc partCount
			mov cx, partCount
			cmp cx, snakeLength
			jg move 
			cmp al, rightChar
			je printRight
			cmp al, upChar
			je printUp
			cmp al, downChar
			je printDown
			cmp al, leftChar
			je printLeft
			
			jmp move
			
			printUp:
			inc ypos
			call upMove
			jmp keepmoving
			
			printDown:
			dec ypos
			call downMove
			jmp keepmoving
			
			printLeft:
			inc xpos
			call leftMove
			jmp keepmoving
			
			printRight:
			dec xpos
			call rightMove
			jmp keepmoving
	move:
	setCursorPos xpos, ypos
	printChar ' ', 00h
	xor ax, ax
	mov al, xpos
	mov tailPosX, ax
	xor ax, ax
	mov al, ypos
	mov tailPosY, ax
	setDigitPos 73, 0
	call displayScore
	mov ax, headPosX
	mov xpos, al
	mov ax, headPosY
	mov ypos, al
	mov partCount, 1
	mov boolCopied, 0
	call waitamillisec
    jmp readchar
        
    mov ax, 4c00h
    int 21h

    main    endp
    end main