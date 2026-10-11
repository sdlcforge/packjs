// TSX fixture; 'react' is treated as external so no React install is needed.
interface GreetingProps {
  name : string
}

function Greeting({ name } : GreetingProps) {
  return <span>Hello, {name}!</span>
}

function testTsx() {
  return <Greeting name="TSX" />
}

export { testTsx }
