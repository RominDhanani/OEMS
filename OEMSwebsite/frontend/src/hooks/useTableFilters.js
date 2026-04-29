import { useState, useMemo } from 'react';

export const useTableFilters = (data, searchKeys = [], dateField = null) => {
    const [searchTerm, setSearchTerm] = useState('');
    const [startDate, setStartDate] = useState('');
    const [endDate, setEndDate] = useState('');
    const [currentPage, setCurrentPage] = useState(1);
    const [itemsPerPage, setItemsPerPage] = useState(10);

    const filteredData = useMemo(() => {
        let result = data;

        // Search Filter
        if (searchTerm) {
            const lowerInfos = searchTerm.toLowerCase();
            result = result.filter(item => {
                return searchKeys.some(key => {
                    const value = item[key];
                    return value && String(value).toLowerCase().includes(lowerInfos);
                });
            });
        }

        // Date Filter
        if (dateField && (startDate || endDate)) {
            result = result.filter(item => {
                const itemDate = new Date(item[dateField]);
                const start = startDate ? new Date(startDate) : null;
                const end = endDate ? new Date(endDate) : null;

                if (start && itemDate < start) return false;
                // Set end date to end of day for inclusive comparison
                if (end) {
                    end.setHours(23, 59, 59, 999);
                    if (itemDate > end) return false;
                }
                return true;
            });
        }

        return result;
    }, [data, searchTerm, startDate, endDate, searchKeys, dateField]);

    // Pagination Logic
    const totalItems = filteredData.length;
    const totalPages = Math.ceil(totalItems / itemsPerPage) || 1;

    // Ensure current page is valid
    if (currentPage > totalPages && totalPages > 0) {
        setCurrentPage(1); // Reset to 1 instead of totalPages to avoid confusion when filtering
    }

    const indexOfLastItem = currentPage * itemsPerPage;
    const indexOfFirstItem = indexOfLastItem - itemsPerPage;
    const currentItems = filteredData.slice(indexOfFirstItem, indexOfLastItem);

    return {
        searchTerm, setSearchTerm,
        startDate, setStartDate,
        endDate, setEndDate,
        currentPage, setCurrentPage,
        itemsPerPage, setItemsPerPage,
        currentItems,
        filteredData,
        totalPages,
        totalItems
    };
};
