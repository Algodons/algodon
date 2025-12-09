import Docker from 'dockerode';

const docker = new Docker();

interface ExecutionResult {
  output: string | null;
  error: string | null;
  exitCode: number;
}

const languageConfigs: Record<string, { image: string; command: string[] }> = {
  python: {
    image: 'python:3.11-slim',
    command: ['python', '-c'],
  },
  javascript: {
    image: 'node:20-slim',
    command: ['node', '-e'],
  },
  typescript: {
    image: 'node:20-slim',
    command: ['ts-node', '-e'],
  },
  go: {
    image: 'golang:1.21-alpine',
    command: ['go', 'run'],
  },
  rust: {
    image: 'rust:1.75-slim',
    command: ['rustc', '-o', '/tmp/out', '-'],
  },
  java: {
    image: 'openjdk:17-slim',
    command: ['javac', '-d', '/tmp', '-'],
  },
  cpp: {
    image: 'gcc:latest',
    command: ['g++', '-o', '/tmp/out', '-'],
  },
};

export async function executeCode(
  language: string,
  code: string,
  input?: string
): Promise<ExecutionResult> {
  const config = languageConfigs[language.toLowerCase()];
  if (!config) {
    throw new Error(`Unsupported language: ${language}`);
  }

  try {
    // Create container
    const container = await docker.createContainer({
      Image: config.image,
      Cmd: [...config.command, code],
      AttachStdout: true,
      AttachStderr: true,
      Tty: false,
      HostConfig: {
        Memory: 512 * 1024 * 1024, // 512MB
        CpuQuota: 100000, // 1 CPU core
        NetworkMode: 'none',
      },
      OpenStdin: !!input,
      StdinOnce: !!input,
    });

    // Start container
    await container.start();

    // Set timeout (30 seconds)
    const timeout = setTimeout(async () => {
      try {
        await container.stop();
        await container.remove();
      } catch (error) {
        // Container may already be stopped
      }
    }, 30000);

    // Attach to container streams
    const stream = await container.attach({
      stream: true,
      stdout: true,
      stderr: true,
    });

    // Send input if provided
    if (input) {
      container.stdin?.write(input);
      container.stdin?.end();
    }

    // Collect output
    let output = '';
    let error = '';

    stream.on('data', (chunk: Buffer) => {
      const data = chunk.toString();
      // Try to determine if it's stdout or stderr
      // This is a simplified approach
      output += data;
    });

    // Wait for container to finish
    const exitCode = await container.wait();
    clearTimeout(timeout);

    // Get logs
    const logs = await container.logs({
      stdout: true,
      stderr: true,
    });

    const logOutput = logs.toString();

    // Clean up
    await container.remove();

    return {
      output: exitCode.StatusCode === 0 ? logOutput : null,
      error: exitCode.StatusCode !== 0 ? logOutput : null,
      exitCode: exitCode.StatusCode || 0,
    };
  } catch (error: any) {
    return {
      output: null,
      error: error.message || 'Execution failed',
      exitCode: 1,
    };
  }
}

