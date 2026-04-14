import { useEffect, useState } from 'react';
import {
  Search,
  ChevronLeft,
  ChevronRight,
  Eye,
  Ban,
  CheckCircle,
  Trash2,
  MoreHorizontal,
  GraduationCap,
  Mail,
  Github,
  Briefcase,
  Award,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { studentsApi } from '@/services/api';
import type { Student } from '@/types';
import { cn } from '@/lib/utils';
import { toast } from 'sonner';

const colleges = ['IIT Delhi', 'IIT Bombay', 'BITS Pilani', 'IIT Kharagpur', 'NIT Trichy'];
const branches = ['CSE', 'IT', 'ECE', 'Design', 'Business'];
const years = [1, 2, 3, 4];
const domains = ['Software Engineering', 'Data Science', 'Product Management', 'UI/UX Design'];

export function Students() {
  const [students, setStudents] = useState<Student[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [perPage] = useState(10);
  const [search, setSearch] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [selectedStudent, setSelectedStudent] = useState<Student | null>(null);
  const [detailDialogOpen, setDetailDialogOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [filters, setFilters] = useState({
    college: '',
    branch: '',
    year: '',
    domain: '',
    status: '',
  });

  useEffect(() => {
    fetchStudents();
  }, [page, search, filters]);

  const fetchStudents = async () => {
    setIsLoading(true);
    try {
      const response = await studentsApi.getStudents(page, perPage, {
        college: filters.college && filters.college !== 'all' ? filters.college : undefined,
        branch: filters.branch && filters.branch !== 'all' ? filters.branch : undefined,
        year: filters.year && filters.year !== 'all' ? parseInt(filters.year) : undefined,
        domain: filters.domain && filters.domain !== 'all' ? filters.domain : undefined,
        status: filters.status && filters.status !== 'all' ? filters.status : undefined,
      }, search);
      setStudents(response.data);
      setTotal(response.total);
    } catch (error) {
      toast.error('Failed to fetch students');
    } finally {
      setIsLoading(false);
    }
  };

  const handleBan = async (id: string, ban: boolean) => {
    try {
      await studentsApi.banStudent(id, ban);
      toast.success(ban ? 'Student banned' : 'Student unbanned');
      fetchStudents();
      if (selectedStudent?.id === id) {
        setSelectedStudent({ ...selectedStudent, status: ban ? 'Banned' : 'Active' });
      }
    } catch (error) {
      toast.error('Failed to update student status');
    }
  };

  const handleDelete = async (id: string) => {
    try {
      await studentsApi.deleteStudent(id);
      toast.success('Student deleted successfully');
      fetchStudents();
      setDeleteDialogOpen(false);
      setDetailDialogOpen(false);
    } catch (error) {
      toast.error('Failed to delete student');
    }
  };

  const getStatusBadge = (status: Student['status']) => {
    const variants: Record<Student['status'], string> = {
      Active: 'bg-green-100 text-green-800 hover:bg-green-100',
      Banned: 'bg-red-100 text-red-800 hover:bg-red-100',
    };
    return (
      <Badge className={cn(variants[status], 'font-medium')}>
        {status}
      </Badge>
    );
  };

  const totalPages = Math.ceil(total / perPage);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Students</h1>
        <p className="text-muted-foreground mt-1">
          Manage student profiles and accounts.
        </p>
      </div>

      {/* Filters */}
      <Card>
        <CardContent className="p-4">
          <div className="flex flex-wrap gap-4">
            <div className="flex-1 min-w-[200px]">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search by name or ID..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>
            <Select
              value={filters.college || 'all'}
              onValueChange={(value) => setFilters({ ...filters, college: value })}
            >
              <SelectTrigger className="w-[150px]">
                <SelectValue placeholder="College" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Colleges</SelectItem>
                {colleges.map((c) => (
                  <SelectItem key={c} value={c}>
                    {c}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Select
              value={filters.branch || 'all'}
              onValueChange={(value) => setFilters({ ...filters, branch: value })}
            >
              <SelectTrigger className="w-[120px]">
                <SelectValue placeholder="Branch" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Branches</SelectItem>
                {branches.map((b) => (
                  <SelectItem key={b} value={b}>
                    {b}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Select
              value={filters.year || 'all'}
              onValueChange={(value) => setFilters({ ...filters, year: value })}
            >
              <SelectTrigger className="w-[100px]">
                <SelectValue placeholder="Year" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Years</SelectItem>
                {years.map((y) => (
                  <SelectItem key={y} value={y.toString()}>
                    Year {y}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Select
              value={filters.domain || 'all'}
              onValueChange={(value) => setFilters({ ...filters, domain: value })}
            >
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="Domain" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Domains</SelectItem>
                {domains.map((d) => (
                  <SelectItem key={d} value={d}>
                    {d}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Button variant="outline" onClick={() => setFilters({ college: 'all', branch: 'all', year: 'all', domain: 'all', status: 'all' })}>
              Clear
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Table */}
      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-muted/50 border-b">
                <tr>
                  <th className="text-left p-4 text-sm font-medium">Student</th>
                  <th className="text-left p-4 text-sm font-medium">College</th>
                  <th className="text-left p-4 text-sm font-medium">Branch</th>
                  <th className="text-left p-4 text-sm font-medium">Year</th>
                  <th className="text-left p-4 text-sm font-medium">CGPA</th>
                  <th className="text-left p-4 text-sm font-medium">Domain</th>
                  <th className="text-left p-4 text-sm font-medium">Skills</th>
                  <th className="text-left p-4 text-sm font-medium">Status</th>
                  <th className="text-left p-4 text-sm font-medium">Actions</th>
                </tr>
              </thead>
              <tbody>
                {isLoading ? (
                  <tr>
                    <td colSpan={9} className="p-8 text-center">
                      <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto"></div>
                    </td>
                  </tr>
                ) : students.length === 0 ? (
                  <tr>
                    <td colSpan={9} className="p-8 text-center text-muted-foreground">
                      No students found.
                    </td>
                  </tr>
                ) : (
                  students.map((student) => (
                    <tr key={student.id} className="border-b hover:bg-muted/50">
                      <td className="p-4">
                        <div className="flex items-center gap-3">
                          <Avatar className="h-8 w-8">
                            <AvatarImage src={student.avatar} />
                            <AvatarFallback className="bg-primary text-primary-foreground text-xs">
                              {student.name.charAt(0)}
                            </AvatarFallback>
                          </Avatar>
                          <div>
                            <div className="font-medium">{student.name}</div>
                            <div className="text-xs text-muted-foreground">{student.studentId}</div>
                          </div>
                        </div>
                      </td>
                      <td className="p-4">{student.college}</td>
                      <td className="p-4">{student.branch}</td>
                      <td className="p-4">{student.year}</td>
                      <td className="p-4">{student.cgpa}</td>
                      <td className="p-4">{student.domain}</td>
                      <td className="p-4">{student.skillsCount}</td>
                      <td className="p-4">{getStatusBadge(student.status)}</td>
                      <td className="p-4">
                        <div className="flex items-center gap-2">
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => {
                              setSelectedStudent(student);
                              setDetailDialogOpen(true);
                            }}
                          >
                            <Eye className="h-4 w-4" />
                          </Button>
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" size="icon">
                                <MoreHorizontal className="h-4 w-4" />
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                              <DropdownMenuItem
                                onClick={() => handleBan(student.id, student.status === 'Active')}
                              >
                                {student.status === 'Active' ? (
                                  <>
                                    <Ban className="h-4 w-4 mr-2 text-red-600" />
                                    Ban Account
                                  </>
                                ) : (
                                  <>
                                    <CheckCircle className="h-4 w-4 mr-2 text-green-600" />
                                    Unban Account
                                  </>
                                )}
                              </DropdownMenuItem>
                            </DropdownMenuContent>
                          </DropdownMenu>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          <div className="flex items-center justify-between p-4 border-t">
            <div className="text-sm text-muted-foreground">
              Showing {(page - 1) * perPage + 1} to {Math.min(page * perPage, total)} of {total} entries
            </div>
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setPage(page - 1)}
                disabled={page === 1}
              >
                <ChevronLeft className="h-4 w-4" />
              </Button>
              <span className="text-sm">
                Page {page} of {totalPages}
              </span>
              <Button
                variant="outline"
                size="sm"
                onClick={() => setPage(page + 1)}
                disabled={page === totalPages}
              >
                <ChevronRight className="h-4 w-4" />
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Detail Dialog */}
      <Dialog open={detailDialogOpen} onOpenChange={setDetailDialogOpen}>
        <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Student Profile</DialogTitle>
            <DialogDescription>
              View complete student profile and application history.
            </DialogDescription>
          </DialogHeader>
          {selectedStudent && (
            <Tabs defaultValue="profile" className="w-full">
              <TabsList className="grid w-full grid-cols-3">
                <TabsTrigger value="profile">Profile</TabsTrigger>
                <TabsTrigger value="skills">Skills & Projects</TabsTrigger>
                <TabsTrigger value="history">Application History</TabsTrigger>
              </TabsList>

              <TabsContent value="profile" className="space-y-4">
                <div className="flex items-center gap-4">
                  <Avatar className="h-20 w-20">
                    <AvatarImage src={selectedStudent.avatar} />
                    <AvatarFallback className="bg-primary text-primary-foreground text-2xl">
                      {selectedStudent.name.charAt(0)}
                    </AvatarFallback>
                  </Avatar>
                  <div>
                    <h3 className="text-xl font-semibold">{selectedStudent.name}</h3>
                    <p className="text-muted-foreground">{selectedStudent.studentId}</p>
                    <div className="flex items-center gap-2 mt-2">
                      {getStatusBadge(selectedStudent.status)}
                    </div>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-1">
                    <label className="text-sm text-muted-foreground">Email</label>
                    <div className="flex items-center gap-2">
                      <Mail className="h-4 w-4" />
                      <span>{selectedStudent.email}</span>
                    </div>
                  </div>
                  <div className="space-y-1">
                    <label className="text-sm text-muted-foreground">College</label>
                    <div className="flex items-center gap-2">
                      <GraduationCap className="h-4 w-4" />
                      <span>{selectedStudent.college}</span>
                    </div>
                  </div>
                  <div className="space-y-1">
                    <label className="text-sm text-muted-foreground">Branch</label>
                    <span>{selectedStudent.branch}</span>
                  </div>
                  <div className="space-y-1">
                    <label className="text-sm text-muted-foreground">Year</label>
                    <span>Year {selectedStudent.year}</span>
                  </div>
                  <div className="space-y-1">
                    <label className="text-sm text-muted-foreground">CGPA</label>
                    <span className="font-semibold">{selectedStudent.cgpa}</span>
                  </div>
                  <div className="space-y-1">
                    <label className="text-sm text-muted-foreground">Domain</label>
                    <span>{selectedStudent.domain}</span>
                  </div>
                  <div className="space-y-1">
                    <label className="text-sm text-muted-foreground">Joined On</label>
                    <span>{selectedStudent.joinedOn}</span>
                  </div>
                  <div className="space-y-1">
                    <label className="text-sm text-muted-foreground">GitHub</label>
                    <div className="flex items-center gap-2">
                      <Github className="h-4 w-4" />
                      <span className="text-sm">{selectedStudent.githubRepos.length} repos</span>
                    </div>
                  </div>
                </div>
              </TabsContent>

              <TabsContent value="skills" className="space-y-4">
                <div>
                  <h4 className="font-semibold mb-2">Skills</h4>
                  <div className="flex flex-wrap gap-2">
                    {selectedStudent.skills.map((skill) => (
                      <Badge key={skill} variant="secondary">
                        {skill}
                      </Badge>
                    ))}
                  </div>
                </div>

                <div>
                  <h4 className="font-semibold mb-2">Projects</h4>
                  {selectedStudent.projects.length === 0 ? (
                    <p className="text-muted-foreground text-sm">No projects listed.</p>
                  ) : (
                    <div className="space-y-3">
                      {selectedStudent.projects.map((project) => (
                        <div key={project.id} className="p-3 bg-muted rounded-lg">
                          <h5 className="font-medium">{project.title}</h5>
                          <p className="text-sm text-muted-foreground">{project.description}</p>
                          <div className="flex flex-wrap gap-1 mt-2">
                            {project.technologies.map((tech) => (
                              <Badge key={tech} variant="outline" className="text-xs">
                                {tech}
                              </Badge>
                            ))}
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>

                <div>
                  <h4 className="font-semibold mb-2">Certifications</h4>
                  {selectedStudent.certifications.length === 0 ? (
                    <p className="text-muted-foreground text-sm">No certifications listed.</p>
                  ) : (
                    <div className="space-y-2">
                      {selectedStudent.certifications.map((cert) => (
                        <div key={cert.id} className="flex items-center gap-2">
                          <Award className="h-4 w-4 text-yellow-500" />
                          <span className="text-sm">{cert.name}</span>
                          <span className="text-xs text-muted-foreground">({cert.issuer})</span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>

                <div>
                  <h4 className="font-semibold mb-2">Prior Internships</h4>
                  {selectedStudent.priorInternships.length === 0 ? (
                    <p className="text-muted-foreground text-sm">No prior internships.</p>
                  ) : (
                    <div className="space-y-2">
                      {selectedStudent.priorInternships.map((internship) => (
                        <div key={internship.id} className="flex items-center gap-2">
                          <Briefcase className="h-4 w-4 text-blue-500" />
                          <span className="text-sm">{internship.role}</span>
                          <span className="text-xs text-muted-foreground">at {internship.company}</span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </TabsContent>

              <TabsContent value="history" className="space-y-4">
                <p className="text-muted-foreground">Application history will be displayed here.</p>
              </TabsContent>
            </Tabs>
          )}

          <DialogFooter className="gap-2">
            {selectedStudent && (
              <>
                <Button
                  variant="outline"
                  onClick={() => handleBan(selectedStudent.id, selectedStudent.status === 'Active')}
                >
                  {selectedStudent.status === 'Active' ? (
                    <>
                      <Ban className="h-4 w-4 mr-2" />
                      Ban Account
                    </>
                  ) : (
                    <>
                      <CheckCircle className="h-4 w-4 mr-2" />
                      Unban Account
                    </>
                  )}
                </Button>
                <Button
                  variant="destructive"
                  onClick={() => setDeleteDialogOpen(true)}
                >
                  <Trash2 className="h-4 w-4 mr-2" />
                  Delete Profile
                </Button>
              </>
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <Dialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Delete Student Profile</DialogTitle>
            <DialogDescription>
              Are you sure you want to delete this student profile? This action cannot be undone.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeleteDialogOpen(false)}>
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={() => selectedStudent && handleDelete(selectedStudent.id)}
            >
              Delete
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
