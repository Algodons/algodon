import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { getDbConnection } from '@/lib/db/oracle';

export async function GET(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const connection = await getDbConnection();
    
    const result = await connection.execute(
      `SELECT id, name, description, language, is_public, created_at, updated_at, last_executed_at
       FROM projects
       WHERE user_id = :userId
       ORDER BY updated_at DESC`,
      { userId }
    );

    await connection.close();

    const projects = (result.rows || []).map((row: any[]) => ({
      id: row[0],
      name: row[1],
      description: row[2],
      language: row[3],
      isPublic: row[4] === 1,
      createdAt: row[5]?.toISOString() || new Date().toISOString(),
      updatedAt: row[6]?.toISOString() || new Date().toISOString(),
      lastExecutedAt: row[7]?.toISOString() || null,
    }));

    return NextResponse.json(projects);
  } catch (error) {
    console.error('Failed to fetch projects:', error);
    return NextResponse.json(
      { error: 'Failed to fetch projects' },
      { status: 500 }
    );
  }
}

export async function POST(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { name, description, language, isPublic } = await req.json();

    if (!name || !language) {
      return NextResponse.json(
        { error: 'Name and language are required' },
        { status: 400 }
      );
    }

    const connection = await getDbConnection();
    const projectId = `proj_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    await connection.execute(
      `INSERT INTO projects (id, user_id, name, description, language, is_public)
       VALUES (:id, :userId, :name, :description, :language, :isPublic)`,
      {
        id: projectId,
        userId,
        name,
        description: description || null,
        language,
        isPublic: isPublic ? 1 : 0,
      }
    );

    await connection.commit();
    await connection.close();

    return NextResponse.json({ id: projectId, name, description, language, isPublic });
  } catch (error) {
    console.error('Failed to create project:', error);
    return NextResponse.json(
      { error: 'Failed to create project' },
      { status: 500 }
    );
  }
}
