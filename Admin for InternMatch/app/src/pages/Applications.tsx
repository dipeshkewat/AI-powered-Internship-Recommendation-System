import { useEffect, useState } from 'react';
import {
  Search,
  ChevronLeft,
  ChevronRight,
  Eye,
  CheckCircle,
  XCircle,
  Clock,
  MoreHorizontal,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';
import {
  Dialog,
  DialogContent,
  DialogDescription,
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
import { applicationsApi } from '@/services/api';
import type { Application, ApplicationStatus } from '@/types';
import { cn } from '@/lib/utils';
import { toast } from 'sonner';

const domains = [
  'Software Engineering',
  'Data Science',
  'Product Management',
  'UI/UX Design',
  'Marketing',
  'Finance',
];

const companies = ['Google', 'Microsoft', 'Amazon', 'Meta', 'Netflix', 'Uber'];
const statuses: ApplicationStatus[] = ['Applied', 'Reviewed', 'Shortlisted', 'Rejected'];

export function Applications() {
  const [applications, setApplications] = useState<Application[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [perPage] = useState(10);
  const [search, setSearch] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [selectedApplication, setSelectedApplication] = useState<Application | null>(null);
  const [detailDialogOpen, setDetailDialogOpen] = useState(false);
  const [filters, setFilters] = useState({
    domain: '',
    company: '',
    status: '',
  });

  useEffect(() => {
    fetchApplications();
  }, [page, search, filters]);

  const fetchApplications = async () => {
    setIsLoading(true);
    try {
      const response = await applicationsApi.getApplications(page, perPage, {
        domain: filters.domain && filters.domain !== 'all' ? filters.domain : undefined,
        company: filters.company && filters.company !== 'all' ? filters.company : undefined,
        status: filters.status && filters.status !== 'all' ? (filters.status as ApplicationStatus) : undefined,
      }, search);
      setApplications(response.data);
      setTotal(response.total);
    } catch (error) {
      toast.error('Failed to fetch applications');
    } finally {
      setIsLoading(false);
    }
  };

  const handleStatusUpdate = async (id: string, status: ApplicationStatus) => {
    try {
      await applicationsApi.updateStatus(id, status);
      toast.success(`Application status updated to ${status}`);
      fetchApplications();
      if (selectedApplication?.id === id) {
        setSelectedApplication({ ...selectedApplication, status });
      }
    } catch (error) {
      toast.error('Failed to update status');
    }
  };

  const getStatusBadge = (status: ApplicationStatus) => {
    const variants: Record<ApplicationStatus, string> = {
      Applied: 'bg-blue-100 text-blue-800 hover:bg-blue-100',
      Reviewed: 'bg-yellow-100 text-yellow-800 hover:bg-yellow-100',
      Shortlisted: 'bg-green-100 text-green-800 hover:bg-green-100',
      Rejected: 'bg-red-100 text-red-800 hover:bg-red-100',
    };
    return (
      <Badge className={cn(variants[status], 'font-medium')}>
        {status}
      </Badge>
    );
  };

  const getMatchScoreColor = (score: number) => {
    if (score >= 85) return 'text-green-600';
    if (score >= 70) return 'text-yellow-600';
    return 'text-red-600';
  };

  const totalPages = Math.ceil(total / perPage);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Applications</h1>
        <p className="text-muted-foreground mt-1">
          Review and manage student applications.
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
                  placeholder="Search by student name..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>
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
            <Select
              value={filters.company || 'all'}
              onValueChange={(value) => setFilters({ ...filters, company: value })}
            >
              <SelectTrigger className="w-[150px]">
                <SelectValue placeholder="Company" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Companies</SelectItem>
                {companies.map((c) => (
                  <SelectItem key={c} value={c}>
                    {c}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Select
              value={filters.status || 'all'}
              onValueChange={(value) => setFilters({ ...filters, status: value })}
            >
              <SelectTrigger className="w-[150px]">
                <SelectValue placeholder="Status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Statuses</SelectItem>
                {statuses.map((s) => (
                  <SelectItem key={s} value={s}>
                    {s}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Button variant="outline" onClick={() => setFilters({ domain: 'all', company: 'all', status: 'all' })}>
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
                  <th className="text-left p-4 text-sm font-medium">Domain</th>
                  <th className="text-left p-4 text-sm font-medium">Company</th>
                  <th className="text-left p-4 text-sm font-medium">Internship</th>
                  <th className="text-left p-4 text-sm font-medium">Applied On</th>
                  <th className="text-left p-4 text-sm font-medium">Status</th>
                  <th className="text-left p-4 text-sm font-medium">Match Score</th>
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
                ) : applications.length === 0 ? (
                  <tr>
                    <td colSpan={9} className="p-8 text-center text-muted-foreground">
                      No applications found.
                    </td>
                  </tr>
                ) : (
                  applications.map((application) => (
                    <tr key={application.id} className="border-b hover:bg-muted/50">
                      <td className="p-4">
                        <div className="font-medium">{application.studentName}</div>
                      </td>
                      <td className="p-4">{application.studentCollege}</td>
                      <td className="p-4">{application.domain}</td>
                      <td className="p-4">{application.company}</td>
                      <td className="p-4">{application.internshipTitle}</td>
                      <td className="p-4">{application.appliedOn}</td>
                      <td className="p-4">{getStatusBadge(application.status)}</td>
                      <td className="p-4">
                        <span className={cn('font-semibold', getMatchScoreColor(application.matchScore))}>
                          {application.matchScore}%
                        </span>
                      </td>
                      <td className="p-4">
                        <div className="flex items-center gap-2">
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => {
                              setSelectedApplication(application);
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
                                onClick={() => handleStatusUpdate(application.id, 'Reviewed')}
                              >
                                <Clock className="h-4 w-4 mr-2" />
                                Mark as Reviewed
                              </DropdownMenuItem>
                              <DropdownMenuItem
                                onClick={() => handleStatusUpdate(application.id, 'Shortlisted')}
                              >
                                <CheckCircle className="h-4 w-4 mr-2 text-green-600" />
                                Shortlist
                              </DropdownMenuItem>
                              <DropdownMenuItem
                                onClick={() => handleStatusUpdate(application.id, 'Rejected')}
                              >
                                <XCircle className="h-4 w-4 mr-2 text-red-600" />
                                Reject
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
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>Application Details</DialogTitle>
            <DialogDescription>
              Review the application details and update status.
            </DialogDescription>
          </DialogHeader>
          {selectedApplication && (
            <div className="space-y-6">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Student</label>
                  <p className="text-lg font-semibold">{selectedApplication.studentName}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-muted-foreground">College</label>
                  <p>{selectedApplication.studentCollege}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Domain</label>
                  <p>{selectedApplication.domain}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Company</label>
                  <p>{selectedApplication.company}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Internship</label>
                  <p>{selectedApplication.internshipTitle}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Applied On</label>
                  <p>{selectedApplication.appliedOn}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Status</label>
                  <div className="mt-1">{getStatusBadge(selectedApplication.status)}</div>
                </div>
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Match Score</label>
                  <p className={cn('text-lg font-semibold', getMatchScoreColor(selectedApplication.matchScore))}>
                    {selectedApplication.matchScore}%
                  </p>
                </div>
              </div>

              <div className="flex gap-3 pt-4 border-t">
                <Button
                  onClick={() => handleStatusUpdate(selectedApplication.id, 'Reviewed')}
                  variant="outline"
                >
                  <Clock className="h-4 w-4 mr-2" />
                  Mark Reviewed
                </Button>
                <Button
                  onClick={() => handleStatusUpdate(selectedApplication.id, 'Shortlisted')}
                  className="bg-green-600 hover:bg-green-700"
                >
                  <CheckCircle className="h-4 w-4 mr-2" />
                  Shortlist
                </Button>
                <Button
                  onClick={() => handleStatusUpdate(selectedApplication.id, 'Rejected')}
                  variant="destructive"
                >
                  <XCircle className="h-4 w-4 mr-2" />
                  Reject
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
