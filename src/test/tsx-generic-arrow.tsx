// TSX generic-arrow fixture: '<T,>' is the form that is unambiguous in a .tsx file.
const identity = <T,>(x : T) => x

function testTsxGeneric() {
  return <span>{identity<string>('generic')}</span>
}

export { testTsxGeneric }
