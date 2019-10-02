//
//  GameScene.swift
//  Flash Bird
//
//  Created by Treinamento on 10/1/19.
//  Copyright © 2019 JCAS. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var gameOver = false
    var timer = Timer()
    //UI label
    var score = 0
    let scoreLabel = SKLabelNode()
    let gameOverLabel = SKLabelNode()
    
    enum ColliderType: UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    //MARK: - Configurando os Canos
    @objc func makePipes() {
        //Cano de Cima
        
        //Declarando o tamanho do vão entre os canos.
        let gapAmount = Int.random(in: 2 ..< 6)
        let gapHeight = bird.size.height * CGFloat(gapAmount)
        
        //Declarando propriedades do cano.
        let movePipeAnimation: SKAction = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        let imagePipe1: String = "pipe1.png"
        let pipe1Texture: SKTexture = SKTexture(imageNamed: imagePipe1)
        
        //Atribuindo as propriedades ao cano.
        let pipe = SKSpriteNode(texture: pipe1Texture)
        pipe.physicsBody = SKPhysicsBody(rectangleOf: pipe1Texture.size())
        pipe.physicsBody?.isDynamic = false
        pipe.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipe.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipe.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        pipe.zPosition = -1
        //Configurando a altura dos canos.
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.height / 4
        
        //Adicionado a tela o objeto.
        pipe.position = CGPoint(x: self.frame.midX + self.frame.width, y: pipe1Texture.size().height / 2 + gapHeight + pipeOffset)
        pipe.run(movePipeAnimation)
        self.addChild(pipe)
        
        //Canos de Baixo
        //Declarando propriedades do cano.
        let imagePipe2: String = "pipe2.png"
        let pipe2Texture: SKTexture = SKTexture(imageNamed: imagePipe2)
        
        
        //Atribuindo as propriedades ao cano.
        let pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe2Texture.size())
        pipe2.physicsBody?.isDynamic = false
        pipe2.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        pipe2.zPosition = -1
        
        //Adicionado a tela o objeto.
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: -pipe2Texture.size().height / 2 - gapHeight + pipeOffset)
        pipe2.run(movePipeAnimation)
        self.addChild(pipe2)
        
        //Configurando o espaço entre os canos para pontuação.
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipe1Texture.size().width, height: gapHeight))
        gap.physicsBody?.isDynamic = false
        gap.run(movePipeAnimation)
        gap.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody?.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody?.collisionBitMask = ColliderType.Gap.rawValue
        
        self.addChild(gap)
        
    }
    
    
    //MARK: - Game Over
    func didBegin(_ contact: SKPhysicsContact) {
        if gameOver == false {
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
                score += 1
                scoreLabel.text = String(score)
            } else {
                self.speed = 0
                gameOver = true
                timer.invalidate()
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 30
                gameOverLabel.text = "Game Over! Clique para recomeçar."
                gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                self.addChild(gameOverLabel)
            }
        }
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        setupGame()
    }
    
    func setupGame() {
        //Adicionado os canos na tela.
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
        
        //MARK: - Cenário
        //Declarando as propriedades do cenário.
        let imagemBg: String = "bg.png"
        let bgTexture: SKTexture = SKTexture(imageNamed: imagemBg)
        
        //Configurando efeito de movimento do cenário.
        let movebgAnimation: SKAction = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 7)
        let shiftbgAnimation: SKAction = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
        let makeBrackgroundMove: SKAction = SKAction.repeatForever(SKAction.sequence([movebgAnimation, shiftbgAnimation]))
        
        //Configurando a repetição do cenário.
        var i: CGFloat = 0
        
        while i < 3 {
            //Atribuindo propriedades ao cenário.
            bg = SKSpriteNode(texture: bgTexture)
            
            //Adicionado o cenário na tela e setando seu tamanho.
            bg.position = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY)
            bg.size.height = self.frame.height
            bg.run(makeBrackgroundMove)
            bg.zPosition = -2
            
            self.addChild(bg)
            i = i + 1
        }
        
        //MARK: - Pássaro
        //Declarando propriedades do obejto personagem.
        let imageFlappy1: String = "flappy1.png"
        let imageFlappy2: String = "flappy2.png"
        let birdTexture1: SKTexture = SKTexture(imageNamed: imageFlappy1)
        let birdTexture2: SKTexture = SKTexture(imageNamed: imageFlappy2)
        
        //Animando o objeto personagem.
        let animation: SKAction = SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.03)
        let makeBirdFlap: SKAction = SKAction.repeatForever(animation)
        
        //Atribuindo as propriedades ao objeto personagem e atribuindo seu collider.
        bird = SKSpriteNode(texture: birdTexture1)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture1.size().height / 2)
        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody?.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody?.collisionBitMask = ColliderType.Bird.rawValue
        
        //Adicionado a tela o objeto personagem e rodando a animação.
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bird.run(makeBirdFlap)
        self.addChild(bird)
        
        //MAARK: - Chāo e Céu
        //Configurando o chāo.
        let ground = SKNode()
        
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(ground)
        
        //Configurando o céu.
        let sky = SKNode()
        
        sky.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2)
        sky.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        sky.physicsBody?.isDynamic = false
        self.addChild(sky)
        
        
        //Configurando e adicionado um label na tela.
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.position = CGPoint(x: self.frame.midX / 2, y: self.frame.height / 2 - 150)
        scoreLabel.text = String(score)
        self.addChild(scoreLabel)
    }
    
    //MARK: - Game Begin
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOver == false {  //Configurnado a gravidade do pássaro.
            self.speed = 1
            bird.physicsBody?.isDynamic = true
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 500)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 10))
        } else {
            gameOver = false
            score = 0
            self.speed = 1
            self.removeAllChildren()
            setupGame()
        }
    }
    
    
}
