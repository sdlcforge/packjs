// JSX fixture; 'react' is treated as external so no React install is needed.
function Greeting({ name }) {
  return <div className="greeting">Hello, {name}!</div>
}

function testJsx() {
  return <Greeting name="JSX" />
}

export { testJsx }
