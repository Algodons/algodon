export interface Project {
  id: string;
  userId: string;
  name: string;
  description: string | null;
  language: string;
  isPublic: boolean;
  createdAt: Date;
  updatedAt: Date;
  lastExecutedAt: Date | null;
}

export interface ProjectFile {
  id: string;
  projectId: string;
  path: string;
  content: string;
  language: string;
  createdAt: Date;
  updatedAt: Date;
}
