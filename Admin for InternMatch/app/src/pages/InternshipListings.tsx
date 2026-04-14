import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Plus,
  Search,
  MoreHorizontal,
  Edit,
  Archive,
  ChevronLeft,
  ChevronRight,
  CheckSquare,
  Square,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
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
import { listingsApi } from '@/services/api';
import type { InternshipListing, InternshipMode, InternshipStatus } from '@/types';
import { cn } from '@/lib/utils';
import { toast } from 'sonner';

const domains = [
  'Software Engineering',
  'Data Science',
  'Product Management',
  'UI/UX Design',
  'Marketing',
  'Finance',
  'HR',
  'Sales',
];

const modes: InternshipMode[] = ['Remote', 'Hybrid', 'On-site'];
const statuses: InternshipStatus[] = ['Active', 'Inactive', 'Archived'];

export function InternshipListings() {
  const [listings, setListings] = useState<InternshipListing[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [perPage] = useState(10);
  const [search, setSearch] = useState('');
  const [selectedListings, setSelectedListings] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [listingToDelete, setListingToDelete] = useState<string | null>(null);
  const [filters, setFilters] = useState({
    domain: '',
    mode: '',
    status: '',
  });
  const navigate = useNavigate();

  useEffect(() => {
    fetchListings();
  }, [page, search, filters]);

  const fetchListings = async () => {
    setIsLoading(true);
    try {
      const response = await listingsApi.getListings(page, perPage, {
        domain: filters.domain && filters.domain !== 'all' ? filters.domain : undefined,
        mode: filters.mode && filters.mode !== 'all' ? (filters.mode as InternshipMode) : undefined,
        status: filters.status && filters.status !== 'all' ? (filters.status as InternshipStatus) : undefined,
      }, search);
      setListings(response.data);
      setTotal(response.total);
    } catch (error) {
      toast.error('Failed to fetch listings');
    } finally {
      setIsLoading(false);
    }
  };

  const handleSelectAll = () => {
    if (selectedListings.length === listings.length) {
      setSelectedListings([]);
    } else {
      setSelectedListings(listings.map((l) => l.id));
    }
  };

  const handleSelect = (id: string) => {
    if (selectedListings.includes(id)) {
      setSelectedListings(selectedListings.filter((l) => l !== id));
    } else {
      setSelectedListings([...selectedListings, id]);
    }
  };

  const handleDelete = async (id: string) => {
    try {
      await listingsApi.deleteListing(id);
      toast.success('Listing archived successfully');
      fetchListings();
    } catch (error) {
      toast.error('Failed to archive listing');
    }
    setDeleteDialogOpen(false);
  };

  const handleBulkDelete = async () => {
    try {
      await listingsApi.bulkDelete(selectedListings);
      toast.success(`${selectedListings.length} listings archived`);
      setSelectedListings([]);
      fetchListings();
    } catch (error) {
      toast.error('Failed to archive listings');
    }
  };

  const getStatusBadge = (status: InternshipStatus) => {
    const variants: Record<InternshipStatus, string> = {
      Active: 'bg-green-100 text-green-800 hover:bg-green-100',
      Inactive: 'bg-yellow-100 text-yellow-800 hover:bg-yellow-100',
      Archived: 'bg-gray-100 text-gray-800 hover:bg-gray-100',
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
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Internship Listings</h1>
          <p className="text-muted-foreground mt-1">
            Manage all internship listings on the platform.
          </p>
        </div>
        <Button onClick={() => navigate('/listings/new')}>
          <Plus className="h-4 w-4 mr-2" />
          Add Listing
        </Button>
      </div>

      {/* Filters */}
      <Card>
        <CardContent className="p-4">
          <div className="flex flex-wrap gap-4">
            <div className="flex-1 min-w-[200px]">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search by title or company..."
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
              value={filters.mode || 'all'}
              onValueChange={(value) => setFilters({ ...filters, mode: value })}
            >
              <SelectTrigger className="w-[150px]">
                <SelectValue placeholder="Mode" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Modes</SelectItem>
                {modes.map((m) => (
                  <SelectItem key={m} value={m}>
                    {m}
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
            <Button variant="outline" onClick={() => setFilters({ domain: 'all', mode: 'all', status: 'all' })}>
              Clear
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Bulk Actions */}
      {selectedListings.length > 0 && (
        <div className="flex items-center gap-4 p-3 bg-muted rounded-lg">
          <span className="text-sm font-medium">
            {selectedListings.length} selected
          </span>
          <Button
            variant="destructive"
            size="sm"
            onClick={handleBulkDelete}
          >
            <Archive className="h-4 w-4 mr-2" />
            Archive Selected
          </Button>
        </div>
      )}

      {/* Table */}
      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-muted/50 border-b">
                <tr>
                  <th className="w-12 p-4">
                    <button
                      onClick={handleSelectAll}
                      className="flex items-center justify-center"
                    >
                      {selectedListings.length === listings.length && listings.length > 0 ? (
                        <CheckSquare className="h-5 w-5 text-primary" />
                      ) : (
                        <Square className="h-5 w-5 text-muted-foreground" />
                      )}
                    </button>
                  </th>
                  <th className="text-left p-4 text-sm font-medium">Title</th>
                  <th className="text-left p-4 text-sm font-medium">Company</th>
                  <th className="text-left p-4 text-sm font-medium">Domain</th>
                  <th className="text-left p-4 text-sm font-medium">Mode</th>
                  <th className="text-left p-4 text-sm font-medium">Location</th>
                  <th className="text-left p-4 text-sm font-medium">Stipend</th>
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
                ) : listings.length === 0 ? (
                  <tr>
                    <td colSpan={9} className="p-8 text-center text-muted-foreground">
                      No listings found.
                    </td>
                  </tr>
                ) : (
                  listings.map((listing) => (
                    <tr key={listing.id} className="border-b hover:bg-muted/50">
                      <td className="p-4">
                        <button
                          onClick={() => handleSelect(listing.id)}
                          className="flex items-center justify-center"
                        >
                          {selectedListings.includes(listing.id) ? (
                            <CheckSquare className="h-5 w-5 text-primary" />
                          ) : (
                            <Square className="h-5 w-5 text-muted-foreground" />
                          )}
                        </button>
                      </td>
                      <td className="p-4">
                        <div className="font-medium">{listing.title}</div>
                      </td>
                      <td className="p-4">{listing.company}</td>
                      <td className="p-4">{listing.domain}</td>
                      <td className="p-4">{listing.mode}</td>
                      <td className="p-4">{listing.city}, {listing.country}</td>
                      <td className="p-4">
                        {listing.currency} {listing.stipend.toLocaleString()}
                      </td>
                      <td className="p-4">{getStatusBadge(listing.status)}</td>
                      <td className="p-4">
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" size="icon">
                              <MoreHorizontal className="h-4 w-4" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end">
                            <DropdownMenuItem
                              onClick={() => navigate(`/listings/edit/${listing.id}`)}
                            >
                              <Edit className="h-4 w-4 mr-2" />
                              Edit
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              onClick={() => {
                                setListingToDelete(listing.id);
                                setDeleteDialogOpen(true);
                              }}
                              className="text-red-600"
                            >
                              <Archive className="h-4 w-4 mr-2" />
                              Archive
                            </DropdownMenuItem>
                          </DropdownMenuContent>
                        </DropdownMenu>
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

      {/* Delete Dialog */}
      <Dialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Archive Listing</DialogTitle>
            <DialogDescription>
              Are you sure you want to archive this listing? It will be moved to the archived state.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeleteDialogOpen(false)}>
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={() => listingToDelete && handleDelete(listingToDelete)}
            >
              Archive
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
