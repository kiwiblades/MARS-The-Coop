What is Jest?
JavaScript testing framework that allows developers to write and run tests for their applications. It is widely used for testing JavaScript code, especially in projects that use React. Jest provides a simple and intuitive API for writing tests, making it easy to get started and maintain tests over time.

How to import jest for testing into project:

1. install tools
Install the tools: npm install --save-dev jest supertest

2. add to package.json
"scripts": {
  "test": "node --experimental-vm-modules node_modules/jest/bin/jest.js"
}

3. run command to test
npm test

