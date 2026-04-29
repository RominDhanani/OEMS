import React from 'react';
import { FaChevronLeft, FaChevronRight } from 'react-icons/fa';

const TablePagination = ({
    currentPage,
    setCurrentPage,
    totalPages,
    itemsPerPage,
    setItemsPerPage
}) => {
    return (
        <div className="pagination-container">
            <div className="pagination-rows-selector">
                <label className="pagination-label">Rows per page:</label>
                <select
                    value={itemsPerPage}
                    onChange={(e) => {
                        setItemsPerPage(Number(e.target.value));
                        setCurrentPage(1);
                    }}
                    className="pagination-select"
                >
                    <option value={10}>10</option>
                    <option value={20}>20</option>
                    <option value={50}>50</option>
                    <option value={100}>100</option>
                </select>
            </div>

            <div className="pagination-controls">
                <button
                    onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
                    disabled={currentPage === 1}
                    className="pagination-btn"
                    title="Previous Page"
                >
                    <FaChevronLeft />
                    <span className="btn-text">Previous</span>
                </button>

                <div className="pagination-info">
                    <span className="current-page">{currentPage}</span>
                    <span className="separator">of</span>
                    <span className="total-pages">{totalPages || 1}</span>
                </div>

                <button
                    onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
                    disabled={currentPage === totalPages || totalPages === 0}
                    className="pagination-btn"
                    title="Next Page"
                >
                    <span className="btn-text">Next</span>
                    <FaChevronRight />
                </button>
            </div>
        </div>
    );
};

export default TablePagination;
